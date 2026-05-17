process EXTRACT_PER_CELL_METRICS {
    tag "$sample_id"
    label 'process_medium'

    input:
    tuple val(sample_id), path(markdup_bam), path(markdup_bai)
    path(samplesheet)

    output:
    tuple val(sample_id), path("${sample_id}_per_cell_metrics.csv.gz"), emit: metrics
    tuple val(sample_id), path("${sample_id}_per_cell_metrics.csv.gz.yaml"), emit: metrics_yaml

    script:
    """
    extract_per_cell_metrics.py \
        --bam ${markdup_bam} \
        --samplesheet ${samplesheet} \
        --output ${sample_id}_per_cell_metrics.csv.gz
    """
}
