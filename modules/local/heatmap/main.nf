process PLOTHEATMAP {
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
    val(filename)
  output:
    path("${filename}.pdf")
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        hmmcopy_utils heatmap --reads ${reads} --metrics ${metrics} \
        --output ${filename}.pdf $chromosomes \
        --sidebar_column pick_met
    """

}
