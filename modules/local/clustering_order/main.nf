process ADDCLUSTERINGORDER {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(metrics, stageAs: "?/metrics/*")
    path(metrics_yaml, stageAs: "?/metrics/*")
    path(reads, stageAs: "?/reads/*")
    path(reads_yaml, stageAs: "?/reads/*")
    val(chromosomes)
  output:
    path("metrics.csv.gz"), emit: csv
    path("metrics.csv.gz.yaml"), emit: yaml
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        hmmcopy_utils add-clustering-order \
         --reads ${reads} --output metrics.csv.gz \
         --metrics ${metrics} $chromosomes
    """

}
