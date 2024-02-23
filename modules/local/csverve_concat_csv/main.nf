process CONCATCSV {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
      path(csv_files)
      path(yaml_files)
      val(filename)
      val(drop_duplicates)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit:yaml
  script:
    def infiles = '--in_f ' + csv_files.join(' --in_f ')
    def drop_dups = drop_duplicates ? " --drop_duplicates" : ''
    """
      csverve concat $infiles --out_f ${filename}.csv.gz $drop_dups
    """

}
