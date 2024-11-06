#!/usr/bin/env python

import json
import yaml
import click


@click.command()
@click.argument('json_string')
@click.argument('filename')
def write_yaml_from_json(json_string, filename):
    try:
        data = json.loads(json_string)
        with open(filename, 'w') as yaml_file:
            yaml.dump(data, yaml_file, default_flow_style=False, sort_keys=False)
        click.echo(f"YAML content written to {filename}")
    except json.JSONDecodeError:
        click.echo("Invalid JSON string")


if __name__ == '__main__':
    write_yaml_from_json()
