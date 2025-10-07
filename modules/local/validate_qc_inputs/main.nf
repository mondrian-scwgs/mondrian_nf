process VALIDATEQCINPUTS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(fastqs_csv)
    path(metadata_yaml, stageAs: "?/*")
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        cp ${metadata_yaml} metadata.yaml
    """

}
