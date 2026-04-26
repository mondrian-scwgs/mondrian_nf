#!/usr/bin/env python3
"""
Filter paired FASTQ files to remove reads from contaminated cells.

Reads contamination metrics CSV and filters paired FASTQs to keep only
reads from cells marked as non-contaminated.
"""

import gzip
import csv
import sys


def extract_cb_tag(fastq_header):
    """Extract CB tag from FASTQ header comment"""
    parts = fastq_header.split()
    for part in parts[1:]:
        if part.startswith('CB:Z:'):
            return part[5:]
    return None


def get_read_name(fastq_line):
    """Extract clean read name from FASTQ header"""
    return fastq_line.split()[0].lstrip('@')


def read_contamination_metrics(metrics_file):
    """Load contamination metrics and return set of cells to keep"""
    cells_to_keep = set()
    contaminated_count = 0
    
    with open(metrics_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cell_id = row['cell_id']
            is_contaminated = row['is_contaminated'].lower() == 'true'
            
            if not is_contaminated:
                cells_to_keep.add(cell_id)
            else:
                contaminated_count += 1
    
    print(f'Keeping {len(cells_to_keep)} cells, filtering {contaminated_count} contaminated cells', 
          file=sys.stderr)
    return cells_to_keep


def filter_fastq_pair(r1_input, r2_input, r1_output, r2_output, cells_to_keep):
    """Filter paired FASTQ files to keep only specified cells"""
    
    open_fn_in = gzip.open if r1_input.endswith('.gz') else open
    open_fn_out = gzip.open
    
    reads_kept = 0
    reads_filtered = 0
    
    with open_fn_in(r1_input, 'rt') as f1_in, \
         open_fn_in(r2_input, 'rt') as f2_in, \
         open_fn_out(r1_output, 'wt') as f1_out, \
         open_fn_out(r2_output, 'wt') as f2_out:
        
        while True:
            # Read 4 lines per read
            lines_r1 = [f1_in.readline() for _ in range(4)]
            lines_r2 = [f2_in.readline() for _ in range(4)]
            
            if not lines_r1[0]:
                break
            
            if not all(lines_r1) or not all(lines_r2):
                raise ValueError('Mismatched FASTQ pair files')
            
            # Extract CB tag
            cb_tag = extract_cb_tag(lines_r1[0])
            
            if not cb_tag:
                print(f'Warning: Read without CB tag: {lines_r1[0]}', file=sys.stderr)
                reads_filtered += 1
                continue
            
            # Check if cell should be kept
            if cb_tag in cells_to_keep:
                # Write both R1 and R2
                for line in lines_r1:
                    f1_out.write(line)
                for line in lines_r2:
                    f2_out.write(line)
                reads_kept += 2
            else:
                reads_filtered += 2
    
    print(f'Kept {reads_kept} reads, filtered {reads_filtered} reads', file=sys.stderr)


def main():
    if len(sys.argv) != 5:
        print("Usage: filter_contamination.py <r1_fastq> <r2_fastq> <metrics_csv> <output_prefix>",
              file=sys.stderr)
        sys.exit(1)
    
    r1_input = sys.argv[1]
    r2_input = sys.argv[2]
    metrics_file = sys.argv[3]
    output_prefix = sys.argv[4]
    
    r1_output = f'{output_prefix}_R1.fastq.gz'
    r2_output = f'{output_prefix}_R2.fastq.gz'
    
    # Load cells to keep
    cells_to_keep = read_contamination_metrics(metrics_file)
    
    # Filter FASTQs
    filter_fastq_pair(r1_input, r2_input, r1_output, r2_output, cells_to_keep)


if __name__ == '__main__':
    main()
