process GENERATE_FASTQS {
    time '1h'
    cpus 1
    memory '8 GB'
    label 'process_medium'

    input:
    tuple(
        val(cell_id),
        path(bamfile),
        path(baifile)
    )

    output:
    tuple(
        val(cell_id),
        path("${cell_id}_fastq_R1.fastq.gz"),
        path("${cell_id}_fastq_R2.fastq.gz")
    )

    script:
    """
    samtools fastq -d CB:${cell_id} -1 ${cell_id}_fastq_R1.fastq.gz -2 ${cell_id}_fastq_R2.fastq.gz ${bamfile}
    """
}

process RUN_KRAKEN {
    time '6h'
    cpus 4
    memory '96 GB'
    label 'process_high'

    input:
    tuple(
        val(cell_id),
        path(fastq1),
        path(fastq2),
        path(kraken_db),
        val(kraken_threads)
    )

    output:
    tuple(
        val(cell_id),
        path("${cell_id}_output.txt"),
        path("${cell_id}_report.txt"),
        path("${cell_id}_parsed_table.csv"),
        path("${cell_id}_human_reads.txt"),
        path("${cell_id}_nonhuman_reads.txt")
    )

    script:
    """
    mkdir -p ${cell_id}
    
    # Run Kraken2 classification
    kraken2 \\
        --db ${kraken_db} \\
        --threads ${kraken_threads} \\
        --report ${cell_id}_report.txt \\
        --gzip-compressed \\
        --memory-mapping \\
        --use-names \\
        --paired \\
        ${fastq1} \\
        ${fastq2} \\
        --output ${cell_id}_output.txt
    
    # Parse Kraken2 output using mondrian_utils
    qc_utils parse-kraken-output \\
        --kraken_output_file ${cell_id}_output.txt \\
        --output_table ${cell_id}_parsed_table.csv \\
        --output_human ${cell_id}_human_reads.txt \\
        --output_nonhuman ${cell_id}_nonhuman_reads.txt
    """
}
