process BUILDTAR {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(infiles, stageAs: "?/*")
    val(filename)
  output:
    path("{filename}.tar.gz")
  script:
    def infiles = infiles.join(" ")
    """
        mkdir ${filename}
        cp ${infiles} ${filename}
        tar -cvf ${filename}.tar ${filename}
        gzip ${filename}.tar
    """

}
