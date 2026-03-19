process SAMTOOLS_MARKDUP_BARCODE {
    tag "$sample_id"
    label 'process_medium'

    input:
    tuple val(sample_id), path(sorted_bam)

    output:
    tuple val(sample_id), path("${sample_id}_markdup.bam"), path("${sample_id}_markdup.bam.bai"), emit: bam
    path("${sample_id}_markdup_metrics.txt"), emit: metrics

    script:
    """
    # Mark duplicates with barcode awareness (CB tag)
    samtools markdup \
        -@ ${task.cpus} \
        -s \
        -f ${sample_id}_markdup_metrics.txt \
        --barcode-tag CB \
        ${sorted_bam} \
        ${sample_id}_markdup.bam

    # Index the output BAM
    samtools index ${sample_id}_markdup.bam
    """
}
