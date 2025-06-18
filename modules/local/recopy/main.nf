process RECOPY {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(input_path, stageAs: "?/*")
    val(filename)
  output:
    path("${filename}"), emit: output_path
  script:
    """
        cp ${input_path} ${filename}
    """
}
