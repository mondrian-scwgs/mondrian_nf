process IDENTIFYNORMALS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(reads)
    path(reads_yaml)
    path(metrics)
    path(metrics_yaml)
    path(normal_copy)
    val(aneuploidy_score_threshold)
    val(ploidy_threshold)
    val(filename)
  output:
    path("${filename}.yaml"), emit: normal_yaml
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.pdf"), emit: pdf

  script:
    """
        normalizer_utils identify-normal-cells \
        --reads_data ${reads} \
        --metrics_data ${metrics} \
        --normal_copy ${normal_copy} \
        --output_yaml ${filename}.yaml \
        --output_csv ${filename}.csv.gz \
        --output_plot ${filename}.pdf \
        --aneuploidy_score_threshold ${aneuploidy_score_threshold} \
        --ploidy_threshold ${ploidy_threshold} \
    """

}
