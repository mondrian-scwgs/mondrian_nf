process INFERHAPSMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(csv)
    path(yaml)
    path(barcodes)
    path(variants)
    path(ref_counts)
    path(alt_counts)
    path(metadata_input)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        haplotype_utils generate-count-haps-metadata \
        --csv ${csv} --yaml ${yaml} --barcodes ${barcodes} --variants ${variants} \
        --ref_counts ${ref_counts} --alt_counts ${alt_counts} \
        --metadata_yaml ${metadata_input} \
        --metadata_output metadata.yaml
    """
}
