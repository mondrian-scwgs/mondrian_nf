#!/usr/bin/env python3
"""
Extract per-cell metrics from a merged BAM file with cell barcode (CB) tags.

This script performs a single pass through the BAM file and computes
per-cell metrics equivalent to flagstat, duplicate counts, insert size
distributions, and basic coverage statistics.
"""

from collections import Counter, defaultdict

import pandas as pd
import pysam
import click
from tqdm import tqdm
import csverve


DTYPES = {
    'cell_id': 'category',
    'sample_id': 'category',
    'library_id': 'category',
    'condition': 'str',
    'is_control': 'bool',
    'pick_met': 'str',
    'sample_type': 'str',
    'row': 'int',
    'column': 'int',
    'total_reads': 'int',
    'total_mapped_reads': 'int',
    'paired_mapped_reads': 'int',
    'unpaired_mapped_reads': 'int',
    'unmapped_reads': 'int',
    'total_duplicate_reads': 'int',
    'paired_duplicate_reads': 'int',
    'unpaired_duplicate_reads': 'int',
    'percent_duplicate_reads': 'float',
    'total_properly_paired': 'int',
    'coverage_depth': 'float',
    'coverage_breadth': 'float',
    'median_insert_size': 'float',
    'mean_insert_size': 'float',
    'standard_deviation_insert_size': 'float',
}

SAMPLESHEET_EXCLUDE_COLS = {'readgroup_id', 'flowcellid', 'laneid', 'sequencing_centre', 'fastq1', 'fastq2'}


def load_samplesheet_metadata(samplesheet_path):
    """Load samplesheet and return per-cell metadata (one row per cell_id)."""
    ss = pd.read_csv(samplesheet_path)
    ss = ss.drop(columns=[c for c in SAMPLESHEET_EXCLUDE_COLS if c in ss.columns])
    ss = ss.rename(columns={'cellid': 'cell_id'})
    ss = ss.drop_duplicates(subset=['cell_id'])
    assert not ss['cell_id'].duplicated().any(), "Duplicate cell_id found in samplesheet after dropping duplicates"
    return ss


def create_empty_metrics():
    """Create a new metrics dictionary for a cell."""
    return {
        'total_reads': 0,
        'mapped_reads': 0,
        'paired_mapped_reads': 0,
        'unpaired_mapped_reads': 0,
        'unmapped_reads': 0,
        'duplicate_reads': 0,
        'paired_duplicate_reads': 0,
        'unpaired_duplicate_reads': 0,
        'paired_reads': 0,
        'properly_paired_reads': 0,
        'secondary_alignments': 0,
        'supplementary_alignments': 0,
        'primary_alignments': 0,
        'aligned_bases': 0,
        'covered_bases': 0,
        'insert_sizes': Counter(),
        'mapping_qualities': Counter(),
    }


def extract_per_cell_metrics(bamfile):
    """
    Extract metrics per cell from a BAM file with CB tags.

    Performs a single-pass iteration through the BAM.
    """
    metrics = defaultdict(create_empty_metrics)
    reads_without_cb = 0

    # Get total read count from index if available
    total_reads = None
    try:
        idx_stats = pysam.idxstats(bamfile)
        total_reads = sum(
            int(line.split('\t')[2]) + int(line.split('\t')[3])
            for line in idx_stats.strip().split('\n')
            if line
        )
    except Exception:
        pass

    with pysam.AlignmentFile(bamfile, 'rb') as bam:
        # Compute genome size from @SQ header lines for coverage_depth
        genome_size = sum(sq['LN'] for sq in bam.header.get('SQ', []))

        # Track active coverage intervals per cell for coverage_breadth
        # Since BAM is coordinate-sorted, we only need one interval per cell
        active_intervals = {}  # cell_id -> (chrom, start, end)

        for read in tqdm(bam.fetch(until_eof=True), total=total_reads, desc="Processing reads", unit=" reads"):
            if not read.has_tag('CB'):
                reads_without_cb += 1
                continue

            cell_id = read.get_tag('CB')
            m = metrics[cell_id]

            m['total_reads'] += 1

            if read.is_unmapped:
                m['unmapped_reads'] += 1
            else:
                m['mapped_reads'] += 1
                m['mapping_qualities'][read.mapping_quality] += 1
                if read.is_paired:
                    m['paired_mapped_reads'] += 1
                else:
                    m['unpaired_mapped_reads'] += 1
                # Accumulate aligned bases for coverage_depth (primary, non-dup only)
                if not read.is_secondary and not read.is_supplementary and not read.is_duplicate:
                    m['aligned_bases'] += read.query_alignment_length

                    # Track coverage_breadth intervals (primary, non-dup only)
                    ref_start = read.reference_start
                    ref_end = read.reference_end
                    chrom = read.reference_name

                    if cell_id in active_intervals:
                        prev_chrom, prev_start, prev_end = active_intervals[cell_id]
                        if chrom == prev_chrom and ref_start <= prev_end:
                            # Overlaps or extends current interval
                            active_intervals[cell_id] = (chrom, prev_start, max(prev_end, ref_end))
                        else:
                            # Flush previous interval
                            m['covered_bases'] += prev_end - prev_start
                            active_intervals[cell_id] = (chrom, ref_start, ref_end)
                    else:
                        active_intervals[cell_id] = (chrom, ref_start, ref_end)

            if read.is_duplicate:
                m['duplicate_reads'] += 1
                if read.is_paired:
                    m['paired_duplicate_reads'] += 1
                else:
                    m['unpaired_duplicate_reads'] += 1

            if read.is_paired:
                m['paired_reads'] += 1

            if read.is_proper_pair:
                m['properly_paired_reads'] += 1
                if read.template_length > 0 and not read.is_duplicate:
                    m['insert_sizes'][abs(read.template_length)] += 1

            if read.is_secondary:
                m['secondary_alignments'] += 1
            elif read.is_supplementary:
                m['supplementary_alignments'] += 1
            else:
                m['primary_alignments'] += 1

    if reads_without_cb > 0:
        print(f"Warning: {reads_without_cb} reads had no CB tag and were skipped")

    # Flush remaining active intervals for coverage_breadth
    for cell_id, (chrom, start, end) in active_intervals.items():
        metrics[cell_id]['covered_bases'] += end - start

    return metrics, genome_size


def _stats_from_counter(counter):
    """Compute mean, median, and stdev from a Counter of values."""
    n = sum(counter.values())
    if n == 0:
        return 0, 0, 0

    # mean
    total_sum = sum(val * count for val, count in counter.items())
    mean = total_sum / n

    # median
    mid = (n - 1) / 2
    cumulative = 0
    median = 0
    sorted_keys = sorted(counter)
    for val in sorted_keys:
        cumulative += counter[val]
        if cumulative > mid:
            median = val
            break

    # stdev
    if n > 1:
        variance = sum(count * (val - mean) ** 2 for val, count in counter.items()) / (n - 1)
        std = variance ** 0.5
    else:
        std = 0

    return mean, median, std


def compute_summary_dataframe(metrics, genome_size):
    """Convert raw metrics to a summary DataFrame."""
    rows = []

    for cell_id in sorted(metrics.keys()):
        m = metrics[cell_id]
        total = m['total_reads']

        mean_insert, median_insert, std_insert = _stats_from_counter(m['insert_sizes'])

        percent_duplicates = (m['duplicate_reads'] / total * 100) if total > 0 else 0
        coverage_depth = (m['aligned_bases'] / genome_size) if genome_size > 0 else 0
        coverage_breadth = (m['covered_bases'] / genome_size) if genome_size > 0 else 0

        rows.append({
            'cell_id': cell_id,
            'total_reads': total,
            'total_mapped_reads': m['mapped_reads'],
            'paired_mapped_reads': m['paired_mapped_reads'],
            'unpaired_mapped_reads': m['unpaired_mapped_reads'],
            'unmapped_reads': m['unmapped_reads'],
            'total_duplicate_reads': m['duplicate_reads'],
            'paired_duplicate_reads': m['paired_duplicate_reads'],
            'unpaired_duplicate_reads': m['unpaired_duplicate_reads'],
            'percent_duplicate_reads': percent_duplicates,
            'total_properly_paired': m['properly_paired_reads'],
            'coverage_depth': coverage_depth,
            'coverage_breadth': coverage_breadth,
            'median_insert_size': median_insert,
            'mean_insert_size': mean_insert,
            'standard_deviation_insert_size': std_insert,
        })

    return pd.DataFrame(rows)


@click.command(context_settings={"show_default": True})
@click.option(
    "--bam",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="Input BAM file with CB tags",
)
@click.option(
    "--output",
    required=True,
    type=click.Path(dir_okay=False, writable=True),
    help="Output CSV file for metrics",
)
@click.option(
    "--samplesheet",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="Extended samplesheet CSV with per-cell metadata",
)
@click.option(
    "--insert_size_histograms",
    required=False,
    type=click.Path(dir_okay=False, writable=True),
    help="Optional: output file for insert size histograms (JSON)",
)
def main(bam, output, samplesheet, insert_size_histograms):
    """CLI entry point implemented with Click."""
    click.echo(f"Reading BAM: {bam}")
    metrics, genome_size = extract_per_cell_metrics(bam)

    click.echo(f"Found {len(metrics)} cells with CB tags")
    click.echo(f"Genome size from header: {genome_size:,} bp")

    click.echo("Computing summary statistics...")
    df = compute_summary_dataframe(metrics, genome_size)

    click.echo(f"Merging samplesheet metadata from: {samplesheet}")
    ss_metadata = load_samplesheet_metadata(samplesheet)
    df = df.merge(ss_metadata, on='cell_id', how='left')

    click.echo(f"Writing metrics to: {output}")
    csverve.write_dataframe_to_csv_and_yaml(df, output, DTYPES)

    if insert_size_histograms:
        import json

        histograms = {cell_id: dict(m["insert_sizes"]) for cell_id, m in metrics.items()}
        with open(insert_size_histograms, "w") as f:
            json.dump(histograms, f)
        click.echo(f"Wrote insert size histograms to: {insert_size_histograms}")

    click.echo("Done.")

    for cell_id in sorted(list(metrics.keys()))[:5]:
        click.echo(f"\n  {cell_id}:")
        row = df[df['cell_id'] == cell_id].iloc[0]
        for k, v in row.items():
            if k != "cell_id":
                click.echo(f"    {k}: {v}")


if __name__ == '__main__':
    main()
