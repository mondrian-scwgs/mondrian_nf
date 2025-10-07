process MERGEVCFS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_files, stageAs: '?/*')
    path(vcf_files_tbi, stageAs: '?/*')
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
  script:
    def vcfs = ''
    if (vcf_files instanceof nextflow.util.BlankSeparatedList){
        vcfs = '-I ' + vcf_files.join(' -I ')
    } else {
        vcfs = '-I ' + vcf_files
    }
    """
        set -e
        mkdir tempdir
        gatk MergeVcfs ${vcfs} -O ${filename}.vcf.gz --TMP_DIR tempdir
    """
}
