process MERGESTATS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(stats, stageAs: '?/*')
    val(filename)
  output:
    path("${filename}.stats"), emit: stats
  script:
    def stat = ''
    if (stats instanceof nextflow.util.BlankSeparatedList){
        stat = '-stats ' + stats.join(' -stats ')
    } else {
        stat = '-stats ' + stats
    }
    """
        set -e
        gatk --java-options "-Xmx4G" MergeMutectStats \
            ${stat} -O ${filename}.stats
    """
}
