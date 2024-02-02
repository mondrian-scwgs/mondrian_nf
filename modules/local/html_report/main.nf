process HTMLREPORT {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(metrics, stageAs: "?/metrics/*")
    path(metrics_yaml, stageAs: "?/metrics/*")
    path(gc_metrics, stageAs: "?/reads/*")
    path(gc_metrics_yaml, stageAs: "?/reads/*")
  output:
    path("qcreport.html")
  script:
    """
        hmmcopy_utils generate-html-report \
         --tempdir temp --html qcreport.html \
         --metrics ${metrics} \
         --gc_metrics ${gc_metrics}


    """

}
