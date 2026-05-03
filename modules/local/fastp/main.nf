process FASTP {
    tag "${sample_id}_chunk${chunk_id}"
    label 'process_medium'

    input:
    tuple val(sample_id), val(chunk_id), path(merged_r1), path(merged_r2)

    output:
    tuple val(sample_id), val(chunk_id), path("${sample_id}_chunk${chunk_id}_trimmed_R1.fastq.gz"), path("${sample_id}_chunk${chunk_id}_trimmed_R2.fastq.gz"), emit: trimmed_fastqs
    tuple path("${sample_id}_chunk${chunk_id}_fastp_report.html"), path("${sample_id}_chunk${chunk_id}_fastp_report.json"), emit: reports

    script:
    """
    fastp \
        --in1 ${merged_r1} \
        --in2 ${merged_r2} \
        --out1 ${sample_id}_chunk${chunk_id}_trimmed_R1.fastq.gz \
        --out2 ${sample_id}_chunk${chunk_id}_trimmed_R2.fastq.gz \
        --html ${sample_id}_chunk${chunk_id}_fastp_report.html \
        --json ${sample_id}_chunk${chunk_id}_fastp_report.json \
        --thread ${task.cpus} \
        --detect_adapter_for_pe \
        --length_required 20 \
        --qualified_quality_phred 20 \
        --cut_tail \
        --cut_tail_mean_quality 20
    """
}
