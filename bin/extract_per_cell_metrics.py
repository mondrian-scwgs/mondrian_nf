#!/usr/bin/env python3
"""
Extract per-cell metrics from a merged BAM file with cell barcode (CB) tags.

This script performs a single pass through the BAM file and computes
per-cell metrics equivalent to flagstat, duplicate counts, insert size
distributions, and basic coverage statistics.
"""

import csv
import statistics
from collections import defaultdict

import pysam
import click


def create_empty_metrics():
    """Create a new metrics dictionary for a cell."""
    return {
        'total_reads': 0,
        'mapped_reads': 0,
        'unmapped_reads': 0,
        'duplicate_reads': 0,
        'paired_reads': 0,
        'properly_paired_reads': 0,
        'read1_count': 0,
        'read2_count': 0,
        'secondary_alignments': 0,
        'supplementary_alignments': 0,
        'primary_alignments': 0,
        'insert_sizes': [],
        'mapping_qualities': [],
    }


def extract_per_cell_metrics(bamfile):
    """
    Extract metrics per cell from a BAM file with CB tags.

    Performs a single-pass iteration through the BAM.
    """
    metrics = defaultdict(create_empty_metrics)
    reads_without_cb = 0

    with pysam.AlignmentFile(bamfile, 'rb') as bam:
        for read in bam.fetch(until_eof=True):
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
                m['mapping_qualities'].append(read.mapping_quality)

            if read.is_duplicate:
                m['duplicate_reads'] += 1

            if read.is_paired:
                m['paired_reads'] += 1

            if read.is_proper_pair:
                m['properly_paired_reads'] += 1
                if read.template_length > 0 and not read.is_duplicate:
                    m['insert_sizes'].append(abs(read.template_length))

            if read.is_read1:
                m['read1_count'] += 1
            elif read.is_read2:
                m['read2_count'] += 1

            if read.is_secondary:
                m['secondary_alignments'] += 1
            elif read.is_supplementary:
                m['supplementary_alignments'] += 1
            else:
                m['primary_alignments'] += 1

    if reads_without_cb > 0:
        print(f"Warning: {reads_without_cb} reads had no CB tag and were skipped")

    return metrics


def compute_summary_stats(metrics):
    """Convert raw metrics to summary statistics."""
    summary = {}

    for cell_id, m in metrics.items():
        total = m['total_reads']

        if m['insert_sizes']:
            median_insert = statistics.median(m['insert_sizes'])
            mean_insert = statistics.mean(m['insert_sizes'])
            if len(m['insert_sizes']) > 1:
                std_insert = statistics.stdev(m['insert_sizes'])
            else:
                std_insert = 0
        else:
            median_insert = 0
            mean_insert = 0
            std_insert = 0

        if m['mapping_qualities']:
            mean_mapq = statistics.mean(m['mapping_qualities'])
        else:
            mean_mapq = 0

        percent_mapped = (m['mapped_reads'] / total * 100) if total > 0 else 0
        percent_duplicates = (m['duplicate_reads'] / total * 100) if total > 0 else 0
        percent_properly_paired = (m['properly_paired_reads'] / m['paired_reads'] * 100) if m['paired_reads'] > 0 else 0

        summary[cell_id] = {
            'cell_id': cell_id,
            'total_reads': total,
            'mapped_reads': m['mapped_reads'],
            'unmapped_reads': m['unmapped_reads'],
            'duplicate_reads': m['duplicate_reads'],
            'percent_mapped': round(percent_mapped, 2),
            'percent_duplicates': round(percent_duplicates, 2),
            'paired_reads': m['paired_reads'],
            'properly_paired_reads': m['properly_paired_reads'],
            'percent_properly_paired': round(percent_properly_paired, 2),
            'read1_count': m['read1_count'],
            'read2_count': m['read2_count'],
            'primary_alignments': m['primary_alignments'],
            'secondary_alignments': m['secondary_alignments'],
            'supplementary_alignments': m['supplementary_alignments'],
            'median_insert_size': round(median_insert, 1),
            'mean_insert_size': round(mean_insert, 1),
            'std_insert_size': round(std_insert, 1),
            'mean_mapping_quality': round(mean_mapq, 1),
        }

    return summary


def write_metrics_csv(summary, output_file):
    """Write summary metrics to a CSV file."""
    if not summary:
        print("No cells found with CB tags!")
        return

    fieldnames = list(next(iter(summary.values())).keys())

    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for cell_id in sorted(summary.keys()):
            writer.writerow(summary[cell_id])


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
    "--insert_size_histograms",
    required=False,
    type=click.Path(dir_okay=False, writable=True),
    help="Optional: output file for insert size histograms (JSON)",
)
def main(bam, output, insert_size_histograms):
    """CLI entry point implemented with Click."""
    click.echo(f"Reading BAM: {bam}")
    metrics = extract_per_cell_metrics(bam)

    click.echo(f"Found {len(metrics)} cells with CB tags")

    click.echo("Computing summary statistics...")
    summary = compute_summary_stats(metrics)

    click.echo(f"Writing metrics to: {output}")
    write_metrics_csv(summary, output)

    if insert_size_histograms:
        import json

        histograms = {cell_id: m["insert_sizes"] for cell_id, m in metrics.items()}
        with open(insert_size_histograms, "w") as f:
            json.dump(histograms, f)
        click.echo(f"Wrote insert size histograms to: {insert_size_histograms}")

    click.echo("Done.")

    for cell_id in sorted(summary.keys())[:5]:
        click.echo(f"\n  {cell_id}:")
        for k, v in summary[cell_id].items():
            if k != "cell_id":
                click.echo(f"    {k}: {v}")


if __name__ == '__main__':
    main()
