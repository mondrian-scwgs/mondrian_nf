process EXTRACT_PER_CELL_METRICS {
    tag "$sample_id"
    label 'process_medium'

    input:
    tuple val(sample_id), path(markdup_bam), path(markdup_bai)

    output:
    tuple val(sample_id), path("${sample_id}_per_cell_metrics.csv"), emit: metrics

    script:
    """
    extract_per_cell_metrics.py \
        --bam ${markdup_bam} \
        --output ${sample_id}_per_cell_metrics.csv
    """
}
