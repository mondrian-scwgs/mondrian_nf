process MERGE_CONTAMINATION_METRICS {
    tag "$sample_id"
    container 'python:3.10'

    input:
    tuple val(sample_id), path(metrics_csvs)
    val(reference_genome)
    val(contamination_threshold)

    output:
    tuple val(sample_id), path("${sample_id}_contamination_metrics.csv"), emit: metrics

    script:
    """
    merge_contamination_metrics.py \\
        --input ${metrics_csvs} \\
        --reference ${reference_genome} \\
        --threshold ${contamination_threshold} \\
        --output ${sample_id}_contamination_metrics.csv
    """
}
