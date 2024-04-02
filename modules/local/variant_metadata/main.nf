process VARIANTMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(consensus_maf)
    path(consensus_vcf)
    path(consensus_vcf_idx)
    path(museq_vcf)
    path(museq_vcf_idx)
    path(mutect_vcf)
    path(mutect_vcf_idx)
    path(strelka_snv_vcf)
    path(strelka_snv_vcf_idx)
    path(strelka_indel_vcf)
    path(strelka_indel_vcf_idx)
    path(metadata_input, stageAs: "metadata_file/*")
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        variant_utils generate-variant-metadata \
            --consensus_maf ${consensus_maf} \
            --consensus_vcf ${consensus_vcf} --consensus_vcf ${consensus_vcf_idx} \
            --museq_vcf ${museq_vcf} --museq_vcf ${museq_vcf_idx} \
            --mutect_vcf ${mutect_vcf} --mutect_vcf ${mutect_vcf_idx} \
            --strelka_vcf ${strelka_snv_vcf} --strelka_vcf ${strelka_snv_vcf_idx} \
            --strelka_vcf ${strelka_indel_vcf} --strelka_vcf ${strelka_indel_vcf_idx} \
            --metadata_input ${metadata_input} --metadata_output metadata.yaml
    """
}
