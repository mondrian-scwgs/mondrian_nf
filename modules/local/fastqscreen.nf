process FASTQSCREEN {
    tag "${sample_id}_chunk${chunk_id}"
    container 'quay.io/andrew_mcpherson/fastq_screen:0.15.3'

    input:
    tuple val(sample_id), val(chunk_id), path(fastq_r1), path(fastq_r2)
    path reference_fasta
    path bwa_indices
    val reference_name
    path supplementary_references
    path supplementary_indices
    val supplementary_ref_names

    output:
    tuple val(sample_id), val(chunk_id), path("${fastq_r1.simpleName}.tagged.fixed.fastq.gz"), path("${fastq_r2.simpleName}.tagged.fixed.fastq.gz"), emit: tagged_fastqs
    path "fastq_screen.conf", emit: config

    script:
    def config_lines = "DATABASE\t${reference_name}\t${reference_fasta}\n"
    if (supplementary_references) {
        supplementary_references.eachWithIndex { ref, idx ->
            config_lines += "DATABASE\t${supplementary_ref_names[idx]}\t${ref}\n"
        }
    }
    config_lines += "THREADS\t${task.cpus}\n"

    """
    cat > fastq_screen.conf << 'EOF'
${config_lines}
EOF

    fastq_screen \\
        --aligner bwa \\
        --conf fastq_screen.conf \\
        --outdir . \\
        --tag \\
        ${fastq_r1} \\
        ${fastq_r2}

    fix_fastqscreen_headers.py \\
        ${fastq_r1.simpleName}.tagged.fastq.gz \\
        ${fastq_r1.simpleName}.tagged.fixed.fastq.gz

    fix_fastqscreen_headers.py \\
        ${fastq_r2.simpleName}.tagged.fastq.gz \\
        ${fastq_r2.simpleName}.tagged.fixed.fastq.gz
    """
}
