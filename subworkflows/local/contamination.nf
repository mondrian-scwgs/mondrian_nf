nextflow.enable.dsl=2

include { SPLITBAM } from '../../modules/local/split_bam/main'
include { EXTRACT_FASTQ } from '../../modules/local/contamination/main'
include { KRAKEN_CLASSIFICATION } from '../../modules/local/contamination/main'
include { PARSE_KRAKEN } from '../../modules/local/contamination/main'
include { GENERATE_BAM_STATS } from '../../modules/local/contamination/main'
include { GENERATE_CONTAMINATION_TABLE_FIGURES } from '../../modules/local/contamination/main'

workflow MONDRIAN_CONTAMINATION{

    take:
        bam_files
        kraken_db
        num_cores
        sample_id
        hmmcopy_metrics_file
        ncbi_taxonomy_database
        min_percent_aggregate
        min_percent_show
        min_num_taxa_condense

    main:

    // Split BAM by cell barcodes using existing SPLITBAM module
    SPLITBAM(bam_files, num_cores)

    // Extract FASTQ files from each cell BAM
    EXTRACT_FASTQ(SPLITBAM.out.split_bams)

    // Run Kraken2 classification on each cell FASTQ pair
    KRAKEN_CLASSIFICATION(EXTRACT_FASTQ.out, kraken_db, num_cores)

    // Parse Kraken2 output to identify human vs non-human reads
    PARSE_KRAKEN(KRAKEN_CLASSIFICATION.out)

    // Generate BAM statistics for different read subsets
    GENERATE_BAM_STATS(PARSE_KRAKEN.out.join(SPLITBAM.out.split_bams))

    // Collect all per-cell outputs by file type for generate_contamination_table_figures
    kraken_reports = GENERATE_BAM_STATS.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> report }
        .collect()
    
    all_stats = GENERATE_BAM_STATS.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> all_stats }
        .collect()
    
    human_stats = GENERATE_BAM_STATS.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> human_stats }
        .collect()
    
    nonhuman_stats = GENERATE_BAM_STATS.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> nonhuman_stats }
        .collect()

    // Generate contamination analysis tables and figures
    GENERATE_CONTAMINATION_TABLE_FIGURES(
        sample_id,
        kraken_reports,
        all_stats,
        human_stats,
        nonhuman_stats,
        hmmcopy_metrics_file,
        ncbi_taxonomy_database,
        min_percent_aggregate,
        min_percent_show,
        min_num_taxa_condense,
    )
}
