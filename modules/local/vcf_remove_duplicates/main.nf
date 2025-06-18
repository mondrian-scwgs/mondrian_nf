process REMOVEDUPLICATES {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_file)
    val(include_ref_alt)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
  script:
    def refalt = include_ref_alt ? "--include_ref_alt" : ""
    """
        io_utils remove-duplicates --infile ${vcf_file} --outfile ${filename}.vcf \
        ${refalt}
        bgzip ${filename}.vcf
        tabix ${filename}.vcf.gz
    """

}
