process QCMETADATA {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
      path(bam)
      path(bai)
      path(contaminated_bam)
      path(contaminated_bai)
      path(control_bam)
      path(control_bai)
      path(gc_metrics)
      path(gc_metrics_yaml)
      path(metrics)
      path(metrics_yaml)
      path(params)
      path(params_yaml)
      path(segments)
      path(segments_yaml)
      path(reads)
      path(reads_yaml)
      path(heatmap)
      path(qc_report)
      path(alignment_tar)
      path(hmmcopy_tar)
      path(input_meta, stageAs: '?/*')
  output:
    path("output.yaml")
  script:
    """
        qc_utils generate-metadata \
        --bam ${bam} ${bai} \
        --control ${control_bam} ${control_bai} \
        --contaminated ${contaminated_bam} ${contaminated_bai} \
        --gc_metrics ${gc_metrics} ${gc_metrics_yaml} \
        --metrics ${metrics} ${metrics_yaml} \
        --params ${params} ${params_yaml} \
        --segments ${segments} ${segments_yaml} \
        --reads ${reads} ${reads_yaml} \
        --heatmap ${heatmap} \
        --qc_report_html ${qc_report} \
        --alignment_tar ${alignment_tar} \
        --hmmcopy_tar ${hmmcopy_tar} \
        --metadata_output output.yaml \
        --metadata_input ${input_meta}
    """
}
