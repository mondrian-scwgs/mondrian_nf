#!/usr/bin/env python3
"""
fix_fastqscreen_headers.py

fastq_screen --tag appends its #FQST: marker directly onto the last token
of the FASTQ header line with no space separator, corrupting any SAM-style
tag that was already there (e.g. RG:Z:SA1090_128688A_FL001_L001#FQST:000).

BWA mem -C splits the comment field on whitespace to produce SAM tags, so
the corrupted field lands verbatim in the BAM as a broken RG value and no
FS:Z: tag is ever written.

fastq_screen uses two FQST formats:
  - First read in the file:  #FQST:genome1:genome2:...:NNN
  - All subsequent reads:    #FQST:NNN   (genome names omitted)

where N is a single digit: 0 = no hit, 1 = unique hit, 2 = multi hit.

This script fixes each header by:
  1. Parsing the genome order from the first #FQST: occurrence.
  2. Splitting the #FQST: suffix off whatever field it is glued to.
  3. Appending a proper space-separated FS:Z: SAM tag in its place.

Before:
  @read CB:Z:cellid\tRG:Z:SA1090_128688A_FL001_L001#FQST:human:mouse:salmon:012

After:
  @read CB:Z:cellid\tRG:Z:SA1090_128688A_FL001_L001\tFS:Z:human_0,mouse_1,salmon_2

Usage:
    fix_fastqscreen_headers.py <input.fastq[.gz]> <output.fastq[.gz]>
"""

import gzip
import sys


def parse_fqst(fqst_suffix, genome_names):
    """
    Convert a #FQST: suffix to an FS:Z: SAM tag string.

    fqst_suffix  - the raw substring starting with '#FQST:' from the header.
    genome_names - list of genome names cached from the first read, or None if
                   this is the first read (genome names are embedded in the tag).

    Returns a tuple (fs_tag, genome_names) where genome_names is populated on
    the first call and passed back unchanged on subsequent calls.
    """
    content = fqst_suffix[len('#FQST:'):]  # strip leading '#FQST:'
    parts = content.split(':')

    if genome_names is None:
        # First read: format is genome1:genome2:...:NNN
        counts_str = parts[-1]
        genome_names = parts[:-1]
    else:
        # Subsequent reads: format is just NNN
        counts_str = parts[0]

    if len(genome_names) != len(counts_str):
        raise ValueError(
            f"FQST ref/count mismatch: {len(genome_names)} refs vs "
            f"{len(counts_str)} count digits in '{fqst_suffix}'"
        )

    fs_tag = 'FS:Z:' + ','.join(
        f'{ref}_{count}' for ref, count in zip(genome_names, counts_str)
    )
    return fs_tag, genome_names


def fix_header(line, genome_names):
    """
    Fix a single FASTQ header line.

    Returns (fixed_line, genome_names). genome_names is populated from the
    first header and reused for all subsequent ones.
    """
    if '#FQST:' not in line:
        return line, genome_names

    idx = line.index('#FQST:')
    prefix = line[:idx].rstrip()
    fs_tag, genome_names = parse_fqst(line[idx:].rstrip('\n'), genome_names)
    return prefix + '\t' + fs_tag, genome_names


def process_fastq(input_path, output_path):
    open_in = gzip.open if input_path.endswith('.gz') else open
    open_out = gzip.open if output_path.endswith('.gz') else open

    genome_names = None

    with open_in(input_path, 'rt') as fin, open_out(output_path, 'wt') as fout:
        while True:
            header = fin.readline()
            if not header:
                break
            seq = fin.readline()
            plus = fin.readline()
            qual = fin.readline()

            fixed_header, genome_names = fix_header(header.rstrip('\n'), genome_names)
            fout.write(fixed_header + '\n')
            fout.write(seq)
            fout.write(plus)
            fout.write(qual)


def main():
    if len(sys.argv) != 3:
        sys.stderr.write(
            f'Usage: {sys.argv[0]} <input.fastq[.gz]> <output.fastq[.gz]>\n'
        )
        sys.exit(1)
    process_fastq(sys.argv[1], sys.argv[2])


if __name__ == '__main__':
    main()
