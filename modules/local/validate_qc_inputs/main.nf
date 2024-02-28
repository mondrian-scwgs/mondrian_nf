process VALIDATEQCINPUTS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(metadata_yaml, stageAs: "?/*")
    path(fastqs_csv)
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        cp ${metadata_yaml} metadata.yaml
    """

}
