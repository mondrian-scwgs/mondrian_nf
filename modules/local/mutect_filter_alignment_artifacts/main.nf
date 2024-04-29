process FILTERALIGNMENTARTIFACTS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(reference)
    path(reference_fai)
    path(reference_dict)
    path(has_realignment_index_bundle)
    path(realignment_index_bundle)
    path(input_vcf)
    path(input_vcf_tbi)
    path(tumor_bam)
    path(tumor_bai)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
    path("${filename}.vcf.gz.tbi"), emit: csi
  script:
    def realignment_index_arg = has_realignment_index_bundle ? "--bwa-mem-index-image "+realignment_index_bundle : ""
    """
        set -e
        gatk FilterAlignmentArtifacts \
            -R ${reference} \
            -V ${input_vcf} \
            -I ${tumor_bam} \
            ${realignment_index_arg} \
            -O ${filename}.vcf.gz

        bcftools index ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
    """
}
