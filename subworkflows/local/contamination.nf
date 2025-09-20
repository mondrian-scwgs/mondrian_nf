nextflow.enable.dsl=2

include { SPLITBAM } from '../../modules/local/split_bam/main'
include { RUN_KRAKEN     } from '../../modules/local/contamination/main'
include { GENERATE_CONTAMINATION_TABLE_FIGURES } from '../../modules/local/contamination/main'

workflow MONDRIAN_CONTAMINATION{

    take:
        bam_file
        cell_ids_file
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
    SPLITBAM(bam_file, bam_file + ".bai", num_cores)

    // Create channel from split BAMs and extract cell IDs from filenames
    split_bams_ch = SPLITBAM.out.bams
        .flatten()
        .map { bam_file ->
            def cell_id = bam_file.baseName
            tuple(cell_id, bam_file, kraken_db, num_cores)
        }

    // Run Kraken2 classification on each cell BAM
    RUN_KRAKEN(split_bams_ch)

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
