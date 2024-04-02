process SEPARATETUMORANDNORMALBAMS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(bai)
    path(normal_cells_yaml)
    val(filename)
  output:
    path("${filename}_normal.bam"), emit: normal_bam
    path("${filename}_normal.bam.bai"), emit: normal_bai
    path("${filename}_tumor.bam"), emit: tumor_bam
    path("${filename}_tumor.bam.bai"), emit: tumor_bai
  script:
    """
        normalizer_utils separate-normal-and-tumour-cells \
        --infile ${bam} \
        --normal_cells_yaml ${normal_cells_yaml} \
        --normal_output ${filename}_normal.bam \
        --tumour_output ${filename}_tumor.bam
        samtools index ${filename}_normal.bam
        samtools index ${filename}_tumor.bam
    """

}
