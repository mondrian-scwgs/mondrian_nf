process MERGEVCFS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(vcf_files, stageAs: "?/*")
    path(idx_files, stageAs: "?/*")
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: vcf_tbi
  script:
    def input_vcf = ''
    if (vcf_files instanceof nextflow.util.BlankSeparatedList){
        input_vcf = '--infiles ' + vcf_files.join(' --infiles ')
    } else {
        input_vcf = '--infiles ' + vcf_files
    }
    """
        io_utils merge-vcfs ${input_vcf}  --outfile ${filename}.vcf
        bgzip ${filename}.vcf
        tabix ${filename}.vcf.gz
    """
}
