#!/usr/bin/env python3
"""
Add cell barcode (CB) and read group (RG) tags to FASTQ reads.

This script adds CB:Z:<cell_id> and optionally RG:Z:<rg_id> to the read header
comment field. BWA mem with -C flag will transfer these comments to the BAM
as SAM tags.
"""

import gzip
import click


def open_fastq(filepath, mode='rt'):
    """Open a FASTQ file, handling gzip compression."""
    if str(filepath).endswith('.gz'):
        return gzip.open(filepath, mode)
    return open(filepath, mode)


def add_tags_to_fastq(input_fastq, output_fastq, cell_id, rg_id=None):
    """
    Add CB:Z:<cell_id> and RG:Z:<rg_id> tags to each read in the FASTQ file.

    The tags are appended to the read header line as SAM-style comments.
    BWA mem -C will transfer these to the resulting BAM file.
    """
    with open_fastq(input_fastq, 'rt') as infile, \
         open_fastq(output_fastq, 'wt') as outfile:

        line_num = 0
        for line in infile:
            line_num += 1
            position_in_record = (line_num - 1) % 4

            if position_in_record == 0:
                line = line.rstrip('\n')
                # Build tag string
                tags = f"CB:Z:{cell_id}"
                if rg_id:
                    tags += f"\tRG:Z:{rg_id}"

                if ' ' in line:
                    parts = line.split(' ', 1)
                    header = parts[0]
                    existing_comment = parts[1]
                    new_line = f"{header}\t{tags}\t{existing_comment}\n"
                else:
                    new_line = f"{line}\t{tags}\n"
                outfile.write(new_line)
            else:
                outfile.write(line)


@click.command(context_settings={"show_default": True})
@click.option(
    "--input_r1",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="Input R1 FASTQ file",
)
@click.option(
    "--input_r2",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="Input R2 FASTQ file",
)
@click.option(
    "--output_r1",
    required=True,
    type=click.Path(dir_okay=False, writable=True),
    help="Output R1 FASTQ file with tags",
)
@click.option(
    "--output_r2",
    required=True,
    type=click.Path(dir_okay=False, writable=True),
    help="Output R2 FASTQ file with tags",
)
@click.option(
    "--cell_id",
    required=True,
    help="Cell barcode/ID to add as CB tag",
)
@click.option(
    "--rg_id",
    required=False,
    help="Read group ID to add as RG tag (optional)",
)
def main(input_r1, input_r2, output_r1, output_r2, cell_id, rg_id):
    """CLI entry point implemented with Click."""
    tags_msg = f"CB:Z:{cell_id}"
    if rg_id:
        tags_msg += f" RG:Z:{rg_id}"

    click.echo(f"Adding {tags_msg} to R1...")
    add_tags_to_fastq(input_r1, output_r1, cell_id, rg_id)

    click.echo(f"Adding {tags_msg} to R2...")
    add_tags_to_fastq(input_r2, output_r2, cell_id, rg_id)

    click.echo("Done.")


if __name__ == '__main__':
    main()
