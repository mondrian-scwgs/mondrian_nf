process SAMTOOLS_SORT_FIXMATE {
    tag "${sample_id}_chunk${chunk_id}"
    label 'process_high'

    input:
    tuple val(sample_id), val(chunk_id), path(aligned_sam)

    output:
    tuple val(sample_id), val(chunk_id), path("${sample_id}_chunk${chunk_id}_sorted.bam")

    script:
    """
    # Name-sort for fixmate
    samtools sort -n \
        -@ ${task.cpus} \
        -o ${sample_id}_chunk${chunk_id}_namesort.bam \
        ${aligned_sam}

    # Add mate score tags (required for markdup)
    samtools fixmate -m \
        -@ ${task.cpus} \
        ${sample_id}_chunk${chunk_id}_namesort.bam \
        ${sample_id}_chunk${chunk_id}_fixmate.bam

    # Coordinate sort for markdup
    samtools sort \
        -@ ${task.cpus} \
        -o ${sample_id}_chunk${chunk_id}_sorted.bam \
        ${sample_id}_chunk${chunk_id}_fixmate.bam

    # Cleanup intermediate files
    rm -f ${sample_id}_chunk${chunk_id}_namesort.bam ${sample_id}_chunk${chunk_id}_fixmate.bam
    """
}
