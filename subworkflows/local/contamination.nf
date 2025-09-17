nextflow.enable.dsl=2

include { GENERATE_FASTQS } from '../../modules/local/contamination/main'
include { RUN_KRAKEN     } from '../../modules/local/contamination/main'

workflow MONDRIAN_CONTAMINATION{

    take:
        bam_file
        cell_ids_file
        kraken_db
        kraken_threads
        sample_id

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

    // Prepare input for Kraken2
    kraken_input_ch = GENERATE_FASTQS.out
        .map { cell_id, fastq1, fastq2 ->
            tuple(cell_id, fastq1, fastq2, kraken_db, kraken_threads)
        }

    // Run Kraken2 classification
    RUN_KRAKEN(kraken_input_ch)

    emit:
    kraken_results = RUN_KRAKEN.out
    fastq_files = GENERATE_FASTQS.out
    
    // Individual output components for easier access
    kraken_output = RUN_KRAKEN.out.map { cell_id, output, report, table, human, nonhuman -> tuple(cell_id, output) }
    kraken_reports = RUN_KRAKEN.out.map { cell_id, output, report, table, human, nonhuman -> tuple(cell_id, report) }
    parsed_tables = RUN_KRAKEN.out.map { cell_id, output, report, table, human, nonhuman -> tuple(cell_id, table) }
    human_reads = RUN_KRAKEN.out.map { cell_id, output, report, table, human, nonhuman -> tuple(cell_id, human) }
    nonhuman_reads = RUN_KRAKEN.out.map { cell_id, output, report, table, human, nonhuman -> tuple(cell_id, nonhuman) }

}
