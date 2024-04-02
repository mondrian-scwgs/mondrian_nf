process ANEUPLOIDYHEATMAP {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(metrics)
    path(metrics_yaml)
    path(reads)
    path(reads_yaml)
    val(aneuploidy_score)
    val(filename)
  output:
    path("${filename}.pdf"), emit: pdf
  script:
    """
        normalizer_utils aneuploidy-heatmap \
        --metrics ${metrics} \
        --reads ${reads} \
        --output ${filename}.pdf \
        --aneuploidy_score ${aneuploidy_score}
    """

}
