process EXTRACT_CONTAMINATION_METRICS {
    tag "${sample_id}_chunk${chunk_id}"
    container 'quay.io/biocontainers/python:3.10'

    input:
    tuple val(sample_id), val(chunk_id), path(tagged_fastq_r1), path(tagged_fastq_r2)
    val reference_genome
    val contamination_threshold

    output:
    tuple val(sample_id), val(chunk_id), path("${sample_id}_chunk${chunk_id}_contamination_metrics.csv"), emit: metrics

    script:
    """
    extract_contamination.py ${tagged_fastq_r1} ${tagged_fastq_r2} ${reference_genome} ${contamination_threshold} ${sample_id}_chunk${chunk_id}_contamination_metrics.csv
    """
}
