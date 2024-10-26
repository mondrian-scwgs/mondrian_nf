process LUMPYEXPRESS {
    time '48h'
    cpus 12
    memory '48 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(tumor_bam)
    path(normal_discordant, stageAs: 'normal/*')
    path(tumor_discordant, stageAs: 'tumor/*')
    path(normal_split, stageAs: 'normal/*')
    path(tumor_split, stageAs: 'tumor/*')
    val(filename)
  output:
    path("${filename}.vcf"), emit: vcf
  script:
    """
        lumpyexpress -B ${normal_bam},${tumor_bam} -S ${normal_split},${tumor_split} -D ${normal_discordant},${tumor_discordant} -o ${filename}.vcf
    """

}
