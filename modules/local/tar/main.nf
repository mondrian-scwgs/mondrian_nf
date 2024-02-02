process BUILDTAR {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(infiles, stageAs: "?/*")
  output:
    path("consolidated.tar.gz")
  script:
    def infiles = infiles.join(" ")
    """
        mkdir consolidated
        cp ${infiles} consolidated
        tar -cvf consolidated.tar consolidated
        gzip consolidated.tar
    """

}
