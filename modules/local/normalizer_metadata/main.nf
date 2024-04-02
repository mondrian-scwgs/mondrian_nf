process NORMALIZERMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(normal_bai)
    path(tumor_bam)
    path(tumor_bai)
    path(heatmap)
    path(metadata_input)
    path(normal_cells_yaml)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        normalizer_utils separate-tumour-and-normal-metadata \
        --metadata_output metadata.yaml \
        --metadata_input ${metadata_input} \
        --heatmap ${heatmap} \
        --normal_cells_yaml ${normal_cells_yaml} \
        --normal_bam ${normal_bam} ${normal_bai} \
        --tumour_bam ${tumor_bam} ${tumor_bai}
    """
}

process NORMALIZERQCMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(heatmap)
    path(metadata_input)
    path(normal_cells_yaml)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        normalizer_utils separate-tumour-and-normal-metadata \
        --metadata_output metadata.yaml \
        --metadata_input ${metadata_input} \
        --heatmap ${heatmap} \
        --normal_cells_yaml ${normal_cells_yaml}
    """
}
