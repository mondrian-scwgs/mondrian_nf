#!/usr/bin/env python3
"""Merge per-chunk contamination metrics CSVs into a single sample-level CSV.

Sums per-cell read counts across chunks, then re-classifies contamination
status using the supplied threshold.

Expected CSV columns:
    cell_id, is_contaminated, total_reads, reference_hits, reference_multihit,
    <genome>_hits, <genome>_multihit, ...
"""

import argparse
import csv
from collections import defaultdict


def merge_metrics(input_files, reference_genome, threshold, output_file):
    cell_data = defaultdict(lambda: defaultdict(int))
    fieldnames = None

    for f in sorted(input_files):
        with open(f, newline='') as fh:
            reader = csv.DictReader(fh)
            if fieldnames is None:
                fieldnames = reader.fieldnames
            for row in reader:
                cell_id = row['cell_id']
                for col, val in row.items():
                    if col in ('cell_id', 'is_contaminated'):
                        continue
                    try:
                        cell_data[cell_id][col] += int(val)
                    except (ValueError, TypeError):
                        pass

    if fieldnames is None:
        raise ValueError('No input data found in provided metrics files')

    with open(output_file, 'w', newline='') as out_fh:
        writer = csv.DictWriter(out_fh, fieldnames=fieldnames)
        writer.writeheader()
        for cell_id in sorted(cell_data.keys()):
            row = dict(cell_data[cell_id])
            row['cell_id'] = cell_id
            total = row.get('total_reads', 0)
            is_contaminated = False
            if total > 0:
                for col in fieldnames:
                    if col.endswith('_hits') and not col.startswith('reference'):
                        hits = row.get(col, 0)
                        if (hits / total) > threshold:
                            is_contaminated = True
                            break
            row['is_contaminated'] = is_contaminated
            writer.writerow(row)


def main():
    parser = argparse.ArgumentParser(description='Merge per-chunk contamination metrics CSVs')
    parser.add_argument('--input', nargs='+', required=True, help='Per-chunk metrics CSV files')
    parser.add_argument('--reference', required=True, help='Reference genome name')
    parser.add_argument('--threshold', type=float, required=True,
                        help='Contamination fraction threshold')
    parser.add_argument('--output', required=True, help='Output merged metrics CSV path')
    args = parser.parse_args()

    merge_metrics(args.input, args.reference, args.threshold, args.output)


if __name__ == '__main__':
    main()
