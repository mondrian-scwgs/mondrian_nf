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
            -c -p \\
            ${sample_id}_merged_tmp.bam \\
            ${bam_chunks}

        samtools view -H ${sample_id}_merged_tmp.bam | awk '!seen[\$0]++' > deduped_header.sam
        samtools reheader deduped_header.sam ${sample_id}_merged_tmp.bam > ${sample_id}_merged.bam
        rm ${sample_id}_merged_tmp.bam deduped_header.sam
    fi
    """
}
