#!/usr/bin/env python3
"""Split sorted, paired FASTQ files into fixed-size chunks.

Reads all R1 files in sorted order, writes chunks of --reads-per-chunk reads to
${sample_id}_R1_chunk0001.fastq.gz, ${sample_id}_R1_chunk0002.fastq.gz, ...
Repeats identically for R2, so chunk boundaries are aligned.
"""

import argparse
import gzip


def split_fastq(input_files, output_prefix, reads_per_chunk):
    chunk_num = 1
    reads_in_chunk = 0
    out_fh = None

    for input_file in sorted(input_files):
        open_fn = gzip.open if input_file.endswith('.gz') else open
        with open_fn(input_file, 'rt') as fh:
            while True:
                lines = [fh.readline() for _ in range(4)]
                if not lines[0]:
                    break
                if not all(lines):
                    raise ValueError(f'Truncated FASTQ record in {input_file}')
                if out_fh is None:
                    out_fh = gzip.open(f'{output_prefix}{chunk_num:04d}.fastq.gz', 'wt')
                for line in lines:
                    out_fh.write(line)
                reads_in_chunk += 1
                if reads_in_chunk >= reads_per_chunk:
                    out_fh.close()
                    out_fh = None
                    reads_in_chunk = 0
                    chunk_num += 1

    if out_fh is not None:
        out_fh.close()


def main():
    parser = argparse.ArgumentParser(description='Split paired FASTQs into equal-sized chunks')
    parser.add_argument('--r1', nargs='+', required=True, help='R1 FASTQ files')
    parser.add_argument('--r2', nargs='+', required=True, help='R2 FASTQ files')
    parser.add_argument('--sample-id', required=True, help='Sample identifier')
    parser.add_argument('--reads-per-chunk', type=int, required=True,
                        help='Number of read pairs per output chunk')
    args = parser.parse_args()

    split_fastq(args.r1, f'{args.sample_id}_R1_chunk', args.reads_per_chunk)
    split_fastq(args.r2, f'{args.sample_id}_R2_chunk', args.reads_per_chunk)


if __name__ == '__main__':
    main()
