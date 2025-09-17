nextflow.enable.dsl=2

include { GENERATE_FASTQS } from '../../modules/local/contamination/main'
include { RUN_KRAKEN     } from '../../modules/local/contamination/main'

workflow MONDRIAN_CONTAMINATION{

    take:
        bam_file
        cell_ids
        kraken_db
        kraken_threads
        sample_id

    main:

    // Create channel for cell IDs
    cell_ids_ch = Channel
        .fromList(cell_ids)
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

}
