process FILTERVCF {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_file)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
    path("${filename}.vcf.gz.csi"), emit: csi
  script:
    """
        bcftools view -O z -f .,PASS -o ${filename}.vcf.gz ${vcf_file}
        tabix -f -p vcf ${filename}.vcf.gz
        bcftools index ${filename}.vcf.gz
    """
}
