process SAMTOOLS_INDEX {
    cpus 1
    memory '4 GB'
    label 'process_low'

  input:
    tuple val(cell_id), path(bamfile)

  output:
    tuple val(cell_id), path(bamfile), path("${bamfile}.bai"), emit: indexed

  script:
    """
        samtools index ${bamfile}
    """
}
