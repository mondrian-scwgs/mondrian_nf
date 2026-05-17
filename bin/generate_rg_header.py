#!/usr/bin/env python3
"""
Generate @RG header lines from an extended samplesheet CSV.

This script reads the samplesheet and generates unique @RG header lines
for use with BWA mem -H flag.
"""

import csv
import click


def generate_rg_header(samplesheet_path, output_path):
    """
    Generate @RG header lines from samplesheet.

    Each unique read group ID gets one @RG line.
    """
    rg_lines = dict()
    co_lines = dict()

    with open(samplesheet_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # Extract fields
            rg_id = row['readgroup_id']
            sample_id = row['sample_id']
            library_id = row['library_id']
            flowcell_id = row['flowcellid']
            lane_id = row['laneid']
            sequencing_centre = row.get('sequencing_centre', 'UNKNOWN')
            cell_id = row['cellid']

            # Generate @RG line
            # Format: @RG\tID:id\tSM:sample\tLB:library\tPU:platform_unit\tPL:platform\tCN:centre
            rg_line = (
                f"@RG\t"
                f"ID:{rg_id}\t"
                f"SM:{sample_id}\t"
                f"LB:{library_id}\t"
                f"PU:{lane_id}_{flowcell_id}\t"
                f"PL:ILLUMINA\t"
                f"CN:{sequencing_centre}"
            )

            if rg_id in rg_lines:
                assert rg_lines[rg_id] == rg_line, f"Conflicting @RG lines for ID {rg_id}"

            rg_lines[rg_id] = rg_line
            co_lines[cell_id] = f"@CO\tCB:{cell_id}"

    # Write output
    with open(output_path, 'w') as f:
        for rg_id, line in sorted(rg_lines.items()):
            f.write(line + '\n')
        for cell_id, line in sorted(co_lines.items()):
            f.write(line + '\n')

    print(f"Generated {len(rg_lines)} @RG header line(s) and {len(co_lines)} @CO line(s)")


@click.command(context_settings={"show_default": True})
@click.option(
    "--samplesheet",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="Extended samplesheet CSV with sample_id, library_id, etc.",
)
@click.option(
    "--output",
    "output_path",
    required=True,
    type=click.Path(dir_okay=False, writable=True),
    help="Output file for @RG header lines",
)
def main(samplesheet, output_path):
    """CLI entry point implemented with Click."""
    generate_rg_header(samplesheet, output_path)
    click.echo("Done.")


if __name__ == '__main__':
    main()
