process SNVGENOTYPINGMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(vartrix_csv)
    path(vartrix_yaml)
    path(barcodes)
    path(variants)
    path(ref_matrix)
    path(alt_matrix)
    path(pysam_genotyper_csv)
    path(pysam_genotyper_yaml)
    path(metadata_input)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        snv_genotyping_utils generate-metadata \
        --vartrix_outputs ${vartrix_csv} ${vartrix_yaml} \
        ${barcodes} ${variants} ${ref_matrix} ${alt_matrix} \
        --outputs ${pysam_genotyper_csv} ${pysam_genotyper_yaml} \
        --metadata_input ${metadata_input} \
        --metadata_output metadata.yaml
    """
}
