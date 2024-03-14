process CONCATCSV {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
      path(csv_files, stageAs: "?/*")
      path(yaml_files, stageAs: "?/*")
      val(filename)
      val(drop_duplicates)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit:yaml
  script:
    def type=csv_files.getClass()
    def size=csv_files.size()
    def infiles = ''
    if(csv_files.size() == 1){
        infiles = '--in_f ' + csv_files
    } else {
        infiles = '--in_f ' + csv_files.join(' --in_f ')
    }
    def drop_dups = drop_duplicates ? " --drop_duplicates" : ''
    """
      echo ${csv_files}
      echo ${size}
      echo ${infiles}
      csverve concat $infiles --out_f ${filename}.csv.gz $drop_dups
    """

}
