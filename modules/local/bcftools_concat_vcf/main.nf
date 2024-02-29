process BCFTOOLSCONCATVCF {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'


    input:
      tuple(
        val(chromosome),
        path(vcf_files, stageAs: "?/*"),
        path(csi_files, stageAs: "?/*")
      )

    output:
      tuple(
        val(chromosome),
        path("merged_sorted.vcf.gz"),
        path("merged_sorted.vcf.gz.csi")
      )

    script:
    def infiles = vcf_files.join(' ')
    """
        bcftools concat -a -O z -o merged.vcf.gz ${infiles}
        vcf-sort merged.vcf.gz > merged_sorted.vcf
        bgzip merged_sorted.vcf -c > merged_sorted.vcf.gz
        tabix -f -p vcf merged_sorted.vcf.gz
        bcftools index merged_sorted.vcf.gz

    """

}