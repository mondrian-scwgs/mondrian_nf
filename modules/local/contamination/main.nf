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
        val(kraken_threads),
        path(bamfile),
        path(baifile)
    )

    output:
    tuple(
        val(cell_id),
        path("${cell_id}/${cell_id}_report.txt"),
        path("${cell_id}/${cell_id}_all_reads_stats.pickle"),
        path("${cell_id}/${cell_id}_human_reads_stats.pickle"),
        path("${cell_id}/${cell_id}_nonhuman_reads_stats.pickle")
    )

    script:
    """
    mkdir -p ${cell_id}
    
    # Run Kraken2 classification
    kraken2 \\
        --db ${kraken_db} \\
        --threads ${kraken_threads} \\
        --report ${cell_id}/${cell_id}_report.txt \\
        --gzip-compressed \\
        --memory-mapping \\
        --use-names \\
        --paired \\
        ${fastq1} \\
        ${fastq2} \\
        --output ${cell_id}/${cell_id}_output.txt
    
    # Parse Kraken2 output using mondrian_utils
    qc_utils parse-kraken-output \\
        --kraken_output_file ${cell_id}/${cell_id}_output.txt \\
        --output_table ${cell_id}/${cell_id}_parsed_table.csv \\
        --output_human ${cell_id}/${cell_id}_human_reads.txt \\
        --output_nonhuman ${cell_id}/${cell_id}_nonhuman_reads.txt
    
    # Generate BAM stats for all reads from this cell
    samtools view ${bamfile} --tag CB:${cell_id} -b | samtools stats > ${cell_id}/${cell_id}_all_reads_stats.txt
    
    # Generate BAM stats for human reads subset
    samtools view ${bamfile} --qname-file ${cell_id}/${cell_id}_human_reads.txt -b | samtools stats > ${cell_id}/${cell_id}_human_reads_stats.txt
    
    # Generate BAM stats for non-human reads subset  
    samtools view ${bamfile} --qname-file ${cell_id}/${cell_id}_nonhuman_reads.txt -b | samtools stats > ${cell_id}/${cell_id}_nonhuman_reads_stats.txt
    
    # Parse all BAM stats files using mondrian_utils
    qc_utils parse-bamstats --stats_file ${cell_id}/${cell_id}_all_reads_stats.txt --output_file ${cell_id}/${cell_id}_all_reads_stats.pickle
    qc_utils parse-bamstats --stats_file ${cell_id}/${cell_id}_human_reads_stats.txt --output_file ${cell_id}/${cell_id}_human_reads_stats.pickle
    qc_utils parse-bamstats --stats_file ${cell_id}/${cell_id}_nonhuman_reads_stats.txt --output_file ${cell_id}/${cell_id}_nonhuman_reads_stats.pickle
    """
}

process GENERATE_CONTAMINATION_TABLE_FIGURES {
    time '2h'
    cpus 2
    memory '16 GB'
    label 'process_medium'

    input:
    tuple(
        val(library_id),
        path(kraken_report_files),
        path(all_reads_stats_files),
        path(human_reads_stats_files),
        path(nonhuman_reads_stats_files),
        path(hmmcopy_metrics_file),
        path(ncbi_taxonomy_database),
        val(min_percent_aggregate),
        val(min_percent_show),
        val(min_num_taxa_condense)
    )

    output:
    tuple(
        val(library_id),
        path("${library_id}_summary_table.csv"),
        path("${library_id}_multipanel_figure.pdf"),
        path("${library_id}_chip_figure.pdf"),
        path("${library_id}_control_cells.pdf"),
        path("${library_id}_nonhuman_percentage_taxon.csv"),
        path("${library_id}_nonhuman_percentage_clade.csv"),
        path("${library_id}_nonhuman_composition.pdf"),
        path("${library_id}_contam_by_column.pdf")
    )

    script:
    """
    qc_utils generate-contamination-table-figures \\
        \$(for file in ${kraken_report_files}; do echo "--kraken_report_files \$file"; done) \\
        \$(for file in ${all_reads_stats_files}; do echo "--all_reads_stats_files \$file"; done) \\
        \$(for file in ${human_reads_stats_files}; do echo "--human_reads_stats_files \$file"; done) \\
        \$(for file in ${nonhuman_reads_stats_files}; do echo "--nonhuman_reads_stats_files \$file"; done) \\
        --hmmcopy_metrics_filename ${hmmcopy_metrics_file} \\
        --library_id ${library_id} \\
        --summary_table_output ${library_id}_summary_table.csv \\
        --multipanel_figure_output ${library_id}_multipanel_figure.pdf \\
        --chip_figure_output ${library_id}_chip_figure.pdf \\
        --control_cells_output ${library_id}_control_cells.pdf \\
        --nonhuman_percentage_taxon_output ${library_id}_nonhuman_percentage_taxon.csv \\
        --nonhuman_percentage_clade_output ${library_id}_nonhuman_percentage_clade.csv \\
        --nonhuman_composition_output ${library_id}_nonhuman_composition.pdf \\
        --contam_by_column_output ${library_id}_contam_by_column.pdf \\
        --ncbi_taxonomy_database ${ncbi_taxonomy_database} \\
        --min_percent_aggregate ${min_percent_aggregate} \\
        --min_percent_show ${min_percent_show} \\
        --min_num_taxa_condense ${min_num_taxa_condense}
    """
}
