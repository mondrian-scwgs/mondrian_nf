process SAMTOOLS_MERGE_CHUNKS {
    tag "$sample_id"
    label 'process_high'

    input:
    tuple val(sample_id), path(bam_chunks)

    output:
    tuple val(sample_id), path("${sample_id}_merged.bam")

    script:
    """
    bam_files=( ${bam_chunks} )

    if [[ \${#bam_files[@]} -eq 1 ]]; then
        cp "\${bam_files[0]}" ${sample_id}_merged.bam
    else
        samtools merge \\
            -@ ${task.cpus} \\
            -f \\
            ${sample_id}_merged.bam \\
            ${bam_chunks}
    fi
    """
}
