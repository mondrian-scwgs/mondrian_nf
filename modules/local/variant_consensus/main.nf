process VARIANTCONSENSUS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(museq_vcf)
    path(museq_vcf_idx)
    path(strelka_snv_vcf)
    path(strelka_snv_vcf_idx)
    path(strelka_indel_vcf)
    path(strelka_indel_vcf_idx)
    path(mutect_vcf)
    path(mutect_vcf_idx)
    val(chromosomes)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
    path("${filename}.vcf.gz.csi"), emit: csi
    path("counts.csv"), emit: counts
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
      variant_utils consensus --museq_vcf ${museq_vcf} \
         --strelka_snv ${strelka_snv_vcf} --strelka_indel ${strelka_indel_vcf} \
         --mutect_vcf ${mutect_vcf} ${chromosomes} \
         --consensus_output consensus.vcf --counts_output counts.csv

        vcf-sort consensus.vcf > vcf_uncompressed.vcf
        bgzip vcf_uncompressed.vcf -c > ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
        bcftools index ${filename}.vcf.gz
    """

}
