
process BCFTOOLSFILTERHET {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

    input:
      tuple(
        val(chromosome),
        file(bcf),
        file(csi)
      )

    output:
        tuple(
          val(chromosome),
          path('filtered.vcf.gz'),
          path("filtered.vcf.gz.csi"),
          path("filtered.vcf.gz.tbi")
        )
    script:
      """
        bcftools filter -O z \
        -o filtered.vcf.gz \
        -i 'GT[0]="het"' \
        ${bcf}
        bcftools index filtered.vcf.gz
        tabix -f -p vcf filtered.vcf.gz

      """
}