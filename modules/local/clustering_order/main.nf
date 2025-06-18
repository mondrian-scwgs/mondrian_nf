process ADDCLUSTERINGORDER {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(metrics, stageAs: "?/metrics/*")
    path(metrics_yaml, stageAs: "?/metrics/*")
    path(reads, stageAs: "?/reads/*")
    path(reads_yaml, stageAs: "?/reads/*")
    val(chromosomes)
    val(filename)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        hmmcopy_utils add-clustering-order \
         --reads ${reads} --output ${filename}.csv.gz \
         --metrics ${metrics} $chromosomes
    """

}
