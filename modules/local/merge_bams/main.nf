process MERGEBAMS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bams, stageAs: "?/*")
    val(filename)
    val(numcores)
  output:
    path("${filename}.bam"), emit: bam
    path("${filename}.bam.bai"), emit: bai
  script:
    def input_bam = ''
    if (bams instanceof nextflow.util.BlankSeparatedList){
        input_bam = '--inputs ' + bams.join(' --inputs ')
    } else {
        input_bam = '--inputs ' + bams
    }
    """
        variant_utils merge-bams \
        $input_bam \
        --output ${filename}.bam \
        --tempdir temp \
        --threads ${numcores}
        samtools index ${filename}.bam
    """
}
