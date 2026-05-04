process FILTER_FASTQ_BY_CONTAMINATION {
    tag "${sample_id}_chunk${chunk_id}"
    container 'quay.io/biocontainers/python:3.10'

    input:
    tuple val(sample_id), val(chunk_id), path(tagged_fastq_r1), path(tagged_fastq_r2), path(contamination_metrics)

    output:
    tuple val(sample_id), val(chunk_id), path("${sample_id}_chunk${chunk_id}_filtered_R1.fastq.gz"), path("${sample_id}_chunk${chunk_id}_filtered_R2.fastq.gz"), emit: filtered_fastqs

    script:
    """
    filter_contamination.py ${tagged_fastq_r1} ${tagged_fastq_r2} ${contamination_metrics} ${sample_id}_chunk${chunk_id}_filtered
    """
}
