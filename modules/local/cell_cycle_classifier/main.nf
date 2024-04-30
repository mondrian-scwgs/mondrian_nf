process CELLCYCLECLASSIFIER {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_high'

  input:
    path(metrics, stageAs: "?/metrics/*")
    path(metrics_yaml, stageAs: "?/metrics/*")
    path(reads, stageAs: "?/reads/*")
    path(reads_yaml, stageAs: "?/reads/*")
  output:
    path("metrics.csv.gz"), emit: csv
    path("metrics.csv.gz.yaml"), emit: yaml
  script:
    """
        hmmcopy_utils cell-cycle-classifier \
          --reads ${reads} \
          --alignment_metrics ${metrics} \
          --hmmcopy_metrics ${metrics} \
          --output metrics.csv.gz --tempdir temp

    """

}
