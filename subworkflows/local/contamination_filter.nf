//
// Contamination Filter Subworkflow
// Runs fastqscreen on merged, CB-tagged FASTQs and filters out contaminated cells
//

include { FASTQSCREEN } from '../../modules/local/fastqscreen'
include { EXTRACT_CONTAMINATION_METRICS } from '../../modules/local/extract_contamination_metrics'
include { FILTER_FASTQ_BY_CONTAMINATION } from '../../modules/local/filter_fastq_by_contamination'

workflow CONTAMINATION_FILTER {
    take:
    fastqs                     // Channel: tuple(sample_id, merged_r1, merged_r2)
    reference_fasta
    reference_name             // Name of reference genome (e.g., 'human', 'mouse')
    supplementary_references   // Optional: list of supplementary reference paths
    supplementary_ref_names    // Optional: names for supplementary references
    contamination_threshold    // Threshold for marking cell as contaminated (default 0.05)

    main:

    // Step 1: Run fastqscreen on merged, tagged FASTQ
    FASTQSCREEN(
        fastqs,
        reference_fasta,
        BwaUtils.getBwaIndices(reference_fasta).collect { file(it) },
        reference_name,
        supplementary_references,
        supplementary_references.collect { BwaUtils.getBwaIndices(it) }.flatten().collect { file(it) },
        supplementary_ref_names
    )

    // Step 2: Extract per-cell contamination metrics from tagged FASTQs
    // FASTQSCREEN.out.tagged_fastqs: tuple(sample_id, tagged_r1, tagged_r2)
    EXTRACT_CONTAMINATION_METRICS(
        FASTQSCREEN.out.tagged_fastqs,
        reference_name,
        contamination_threshold
    )

    // Step 3: Filter FASTQs to remove contaminated cells
    // Join tagged fastqs with metrics on sample_id before filtering
    FILTER_FASTQ_BY_CONTAMINATION(
        FASTQSCREEN.out.tagged_fastqs,
        EXTRACT_CONTAMINATION_METRICS.out.metrics
    )

    emit:
    fastqs   = FILTER_FASTQ_BY_CONTAMINATION.out.filtered_fastqs  // tuple(sample_id, filtered_r1, filtered_r2)
    metrics  = EXTRACT_CONTAMINATION_METRICS.out.metrics           // tuple(sample_id, contamination_metrics.csv)
}
