nextflow.enable.dsl=2

include { GENERATE_FASTQS } from '../../modules/local/contamination/main'
include { RUN_KRAKEN     } from '../../modules/local/contamination/main'
include { GENERATE_CONTAMINATION_TABLE_FIGURES } from '../../modules/local/contamination/main'

workflow MONDRIAN_CONTAMINATION{

    take:
        bam_file
        cell_ids_file
        kraken_db
        kraken_threads
        sample_id
        hmmcopy_metrics_file
        ncbi_taxonomy_database
        min_percent_aggregate
        min_percent_show
        min_num_taxa_condense

    main:

    // Create channel for cell IDs from a text file (one per line)
    cell_ids_ch = Channel
        .fromPath(cell_ids_file)
        .splitText()
        .map { it.trim() }
        .map { cell_id -> 
            tuple(cell_id, bam_file, bam_file + ".bai")
        }

    // Generate FASTQs from BAM file for each cell
    GENERATE_FASTQS(cell_ids_ch)

    // Prepare input for Kraken2 (including BAM file for stats generation)
    kraken_input_ch = GENERATE_FASTQS.out
        .map { cell_id, fastq1, fastq2 ->
            tuple(cell_id, fastq1, fastq2, kraken_db, kraken_threads, bam_file, bam_file + ".bai")
        }

    // Run Kraken2 classification
    RUN_KRAKEN(kraken_input_ch)

    // Collect all per-cell outputs by file type for generate_contamination_table_figures
    kraken_reports = RUN_KRAKEN.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> report }
        .collect()
    
    all_stats = RUN_KRAKEN.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> all_stats }
        .collect()
    
    human_stats = RUN_KRAKEN.out
        .map { cell_id, report, all_stats, human_stats, nonhuman_stats -> human_stats }
        .collect()
    
    nonhuman_stats = RUN_KRAKEN.out
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

    emit:
    // Only emit the final aggregated results
    contamination_results = GENERATE_CONTAMINATION_TABLE_FIGURES.out

}
