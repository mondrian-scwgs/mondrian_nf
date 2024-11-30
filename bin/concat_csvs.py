#!/usr/bin/env python

import logging
import sys
import pandas as pd
import click


@click.command()
@click.argument('concat_filename')
@click.argument('table_filenames', nargs=-1)
@click.option('--tsv', is_flag=True, default=False)
@click.option('--compressed', is_flag=True, default=False)
def concat_csvs(
        concat_filename,
        table_filenames,
        tsv,
        compressed
    ):

    sep = ','
    if tsv:
        sep = '\t'

    table = []

    for filename in table_filenames:
        table.append(pd.read_csv(filename, comment='#', dtype='str', sep=sep))

    table = pd.concat(table, ignore_index=True)

    if compressed:
        table.to_csv(concat_filename, index=False, sep=sep, compression={'method':'gzip', 'mtime':0, 'compresslevel':9})
    else:
        table.to_csv(concat_filename, index=False, sep=sep)


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.INFO)
    concat_csvs()
