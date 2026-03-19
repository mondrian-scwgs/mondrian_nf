process CONCAT_FASTQS {
    tag "$sample_id"
    label 'process_low'

    input:
    path(tagged_r1_files)
    path(tagged_r2_files)
    val(sample_id)

    output:
    tuple val(sample_id), path("${sample_id}_merged_R1.fastq.gz"), path("${sample_id}_merged_R2.fastq.gz")

    script:
    """
    cat ${tagged_r1_files} > ${sample_id}_merged_R1.fastq.gz
    cat ${tagged_r2_files} > ${sample_id}_merged_R2.fastq.gz
    """
}
