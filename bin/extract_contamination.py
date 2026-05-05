#!/usr/bin/env python3
"""
Extract per-cell contamination metrics from fastqscreen-tagged FASTQs.

Parses fastqscreen organism flags and cell barcodes to generate contamination
classification for each cell based on the fraction of reads mapping to
non-reference organisms.
"""

import gzip
import sys
import csv
from collections import defaultdict


def get_read_name(fastq_line):
    """Extract clean read name from FASTQ header"""
    return fastq_line.split()[0].lstrip('@')


def extract_cb_tag(fastq_header):
    """Extract CB tag from FASTQ header comment"""
    parts = fastq_header.split()
    for part in parts[1:]:
        if part.startswith('CB:Z:'):
            return part[5:]
    return None


def extract_fastqscreen_flags(fastq_header):
    """Extract fastqscreen flags from the FS:Z: SAM tag in a FASTQ header.

    Parses the 'FS:Z:human_0,mouse_1,salmon_2' format produced by
    fix_fastqscreen_headers.py.  Returns a dict of {genome: hit_flag} where
    hit_flag is an int (0 = no hit, 1 = unique hit, 2 = multi hit), or an
    empty dict if no FS:Z: tag is present.
    """
    for part in fastq_header.split()[1:]:
        if part.startswith('FS:Z:'):
            result = {}
            for entry in part[5:].split(','):
                genome, flag = entry.rsplit('_', 1)
                result[genome] = int(flag)
            return result
    return {}


def read_fastq_pairs(r1_file, r2_file):
    """Read paired-end FASTQ files with FS:Z: tags and CB tags"""
    open_fn = gzip.open if r1_file.endswith('.gz') else open

    with open_fn(r1_file, 'rt') as f1, open_fn(r2_file, 'rt') as f2:
        while True:
            # Read 4 lines per read from each file
            lines_r1 = [f1.readline() for _ in range(4)]
            lines_r2 = [f2.readline() for _ in range(4)]

            if not lines_r1[0]:
                break

            if not all(lines_r1) or not all(lines_r2):
                raise ValueError('Mismatched FASTQ pair files')

            header_r1, header_r2 = lines_r1[0], lines_r2[0]

            # Verify read names match
            name_r1 = get_read_name(header_r1)
            name_r2 = get_read_name(header_r2)
            assert name_r1 == name_r2, f'Read name mismatch: {name_r1} vs {name_r2}'

            cb_tag = extract_cb_tag(header_r1)

            flags_r1 = extract_fastqscreen_flags(header_r1)
            flags_r2 = extract_fastqscreen_flags(header_r2)

            assert flags_r1.keys() == flags_r2.keys(), f'Genome keys mismatch between R1 and R2 for read {name_r1}'

            yield cb_tag, flags_r1, flags_r2


def main():
    if len(sys.argv) != 6:
        print("Usage: extract_contamination.py <r1_fastq> <r2_fastq> <reference_genome> <threshold> <output_csv>", 
              file=sys.stderr)
        sys.exit(1)
    
    r1_file = sys.argv[1]
    r2_file = sys.argv[2]
    reference = sys.argv[3]
    threshold = float(sys.argv[4])
    output_file = sys.argv[5] if len(sys.argv) > 5 else 'contamination_metrics.csv'
    
    # Accumulate per-cell statistics
    cell_stats = defaultdict(lambda: {
        'total_reads': 0,
        'genomes': defaultdict(int),
        'multihit': defaultdict(int)
    })
    
    # Track genomes seen
    genomes_seen = set()
    
    for cb_tag, flags_r1, flags_r2 in read_fastq_pairs(r1_file, r2_file):
        if not cb_tag:
            print(f'Warning: Read without CB tag', file=sys.stderr)
            continue
        
        genomes_seen.update(flags_r1.keys())
        genomes_seen.update(flags_r2.keys())
        
        # Count each read end independently (matches original fastqscreen.py)
        # total_reads counts individual read ends (2 per pair)
        cell_stats[cb_tag]['total_reads'] += 2
        
        # R1 hits
        hit_orgs_r1 = [g for g, flag in flags_r1.items() if flag > 0]
        for genome in hit_orgs_r1:
            cell_stats[cb_tag]['genomes'][genome] += 1
        # multihit = read maps to multiple genomes simultaneously
        if len(hit_orgs_r1) > 1:
            for genome in hit_orgs_r1:
                cell_stats[cb_tag]['multihit'][genome] += 1
        
        # R2 hits
        hit_orgs_r2 = [g for g, flag in flags_r2.items() if flag > 0]
        for genome in hit_orgs_r2:
            cell_stats[cb_tag]['genomes'][genome] += 1
        # multihit = read maps to multiple genomes simultaneously
        if len(hit_orgs_r2) > 1:
            for genome in hit_orgs_r2:
                cell_stats[cb_tag]['multihit'][genome] += 1
    
    # Determine contamination status per cell
    genomes_list = sorted(genomes_seen)
    
    with open(output_file, 'w', newline='') as outf:
        writer = csv.DictWriter(
            outf,
            fieldnames=['cell_id', 'is_contaminated', 'total_reads', 'reference_hits', 'reference_multihit'] + 
                       [f'{g}_hits' for g in genomes_list if g != reference] +
                       [f'{g}_multihit' for g in genomes_list if g != reference]
        )
        writer.writeheader()
        
        for cell_id in sorted(cell_stats.keys()):
            stats = cell_stats[cell_id]
            total = stats['total_reads']
            ref_hits = stats['genomes'].get(reference, 0)
            ref_multihit = stats['multihit'].get(reference, 0)
            
            # Contaminated if any non-reference genome exceeds threshold
            is_contaminated = False
            for genome in genomes_list:
                if genome == reference:
                    continue
                hits = stats['genomes'].get(genome, 0)
                if total > 0 and (hits / total) > threshold:
                    is_contaminated = True
                    break
            
            row = {
                'cell_id': cell_id,
                'is_contaminated': str(is_contaminated),
                'total_reads': total,
                'reference_hits': ref_hits,
                'reference_multihit': ref_multihit
            }
            
            # Add other genome counts
            for genome in genomes_list:
                if genome != reference:
                    row[f'{genome}_hits'] = stats['genomes'].get(genome, 0)
                    row[f'{genome}_multihit'] = stats['multihit'].get(genome, 0)
            
            writer.writerow(row)
    
    print(f'Processed {len(cell_stats)} cells', file=sys.stderr)
    contaminated = sum(1 for s in cell_stats.values() if s['genomes'] and max(
        (s['genomes'].get(g, 0) / s['total_reads'] if s['total_reads'] > 0 else 0)
        for g in genomes_list if g != reference
    ) > threshold)
    print(f'Contaminated: {contaminated}', file=sys.stderr)


if __name__ == '__main__':
    main()
