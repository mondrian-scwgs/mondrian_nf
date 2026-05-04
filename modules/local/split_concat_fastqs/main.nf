process SPLIT_CONCAT_FASTQS {
    tag "$sample_id"
    label 'process_medium'

    input:
    path(tagged_r1_files)
    path(tagged_r2_files)
    val(sample_id)
    val(reads_per_chunk)

    output:
    tuple val(sample_id), path("${sample_id}_R1_chunk*.fastq.gz"), path("${sample_id}_R2_chunk*.fastq.gz"), emit: chunks

    script:
    def lines = reads_per_chunk * 4
    """
    zcat \$(printf '%s\\n' ${tagged_r1_files} | sort) \\
        | split -d --suffix-length=4 -l ${lines} \\
            --additional-suffix=.fastq \\
            --filter='gzip -1 > \$FILE.gz' \\
            - '${sample_id}_R1_chunk'

    zcat \$(printf '%s\\n' ${tagged_r2_files} | sort) \\
        | split -d --suffix-length=4 -l ${lines} \\
            --additional-suffix=.fastq \\
            --filter='gzip -1 > \$FILE.gz' \\
            - '${sample_id}_R2_chunk'
    """
}
