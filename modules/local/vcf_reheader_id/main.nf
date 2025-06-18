process REHEADERID {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_file)
    path(normal_bam)
    path(tumor_bam)
    val(tumor_id)
    val(normal_id)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
    path("${filename}.vcf.gz.csi"), emit: csi
  script:
    """
        variant_utils vcf-reheader-id \
        --input ${vcf_file} \
        --tumour ${tumor_bam} \
        --normal ${normal_bam} \
        --output output.vcf.gz \
        --vcf_tumour_id ${tumor_id} \
        --vcf_normal_id ${normal_id}

        vcf-sort output.vcf.gz > vcf_uncompressed.vcf
        bgzip vcf_uncompressed.vcf -c > ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
        bcftools index ${filename}.vcf.gz

    """

}
