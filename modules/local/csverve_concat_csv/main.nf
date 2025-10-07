process CONCATCSV {
    time '24h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
      path(csv_files, stageAs: "?/*")
      path(yaml_files, stageAs: "?/*")
      val(filename)
      val(drop_duplicates)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit:yaml
  script:
    def infiles = ''
    if (csv_files instanceof nextflow.util.BlankSeparatedList){
        infiles = '--in_f ' + csv_files.join(' --in_f ')
    } else {
        infiles = '--in_f ' + csv_files
    }
    def drop_dups = drop_duplicates ? " --drop_duplicates" : ''
    """
      csverve concat ${infiles} --out_f ${filename}.csv.gz $drop_dups
    """

}
