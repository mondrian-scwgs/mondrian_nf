process CSVERVEREMOVEDUPLICATES {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
      path(input_csv)
      path(input_yaml)
      val(filename)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit:yaml
  script:
    """
      csverve remove-duplicates --in_f ${input_csv} --out_f ${filename}.csv.gz
    """

}
