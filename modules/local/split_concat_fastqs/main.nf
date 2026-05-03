process SPLIT_CONCAT_FASTQS {
    tag "$sample_id"
    container 'python:3.10'
    label 'process_medium'

    input:
    path(tagged_r1_files)
    path(tagged_r2_files)
    val(sample_id)
    val(reads_per_chunk)

    output:
    tuple val(sample_id), path("${sample_id}_R1_chunk*.fastq.gz"), path("${sample_id}_R2_chunk*.fastq.gz"), emit: chunks

    script:
    """
    split_fastq_pairs.py \\
        --r1 ${tagged_r1_files} \\
        --r2 ${tagged_r2_files} \\
        --sample-id ${sample_id} \\
        --reads-per-chunk ${reads_per_chunk}
    """
}
