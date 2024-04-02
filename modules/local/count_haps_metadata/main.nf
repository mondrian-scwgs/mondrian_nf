process COUNTHAPSMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(csv)
    path(yaml)
    path(metadata_input)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        haplotype_utils generate-count-haps-metadata \
        --csv ${csv} --yaml ${yaml} \
        --metadata_yaml ${metadata_input} \
        --metadata_output metadata.yaml
    """
}
