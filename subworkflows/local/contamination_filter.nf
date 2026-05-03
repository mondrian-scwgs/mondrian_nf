//
// Contamination Filter Subworkflow
// Runs fastqscreen on CB-tagged FASTQ chunks in parallel and filters out contaminated cells
//

include { FASTQSCREEN } from '../../modules/local/fastqscreen'
include { EXTRACT_CONTAMINATION_METRICS } from '../../modules/local/extract_contamination_metrics'
include { MERGE_CONTAMINATION_METRICS } from '../../modules/local/merge_contamination_metrics'
include { FILTER_FASTQ_BY_CONTAMINATION } from '../../modules/local/filter_fastq_by_contamination'

workflow CONTAMINATION_FILTER {
    take:
    fastqs                     // Channel: tuple(sample_id, chunk_id, r1, r2)
    reference_fasta
    reference_name             // Name of reference genome (e.g., 'human', 'mouse')
    supplementary_references   // Optional: list of supplementary reference paths
    supplementary_ref_names    // Optional: names for supplementary references
    contamination_threshold    // Threshold for marking cell as contaminated (default 0.05)

    main:

    // Step 1: Run fastqscreen on each chunk in parallel
    FASTQSCREEN(
        fastqs,
        reference_fasta,
        BwaUtils.getBwaIndices(reference_fasta).collect { file(it) },
        reference_name,
        supplementary_references,
        supplementary_references.collect { BwaUtils.getBwaIndices(it) }.flatten().collect { file(it) },
        supplementary_ref_names
    )

    // Step 2: Extract per-cell contamination metrics from each chunk
    // FASTQSCREEN.out.tagged_fastqs: tuple(sample_id, chunk_id, tagged_r1, tagged_r2)
    EXTRACT_CONTAMINATION_METRICS(
        FASTQSCREEN.out.tagged_fastqs,
        reference_name,
        contamination_threshold
    )

    // Step 3: Collect all chunk metrics per sample and merge into a single CSV
    // so that contamination classification uses the full read count for each cell
    per_sample_metrics = EXTRACT_CONTAMINATION_METRICS.out.metrics
        .map { sample_id, chunk_id, csv -> [sample_id, csv] }
        .groupTuple()

    MERGE_CONTAMINATION_METRICS(
        per_sample_metrics,
        reference_name,
        contamination_threshold
    )

    // Step 4: Join the merged metrics back with each chunk's tagged FASTQs (by sample_id)
    // then filter each chunk independently using the full-sample metrics
    // combine(by: 0) yields: tuple(sample_id, chunk_id, tagged_r1, tagged_r2, merged_metrics_csv)
    FILTER_FASTQ_BY_CONTAMINATION(
        FASTQSCREEN.out.tagged_fastqs
            .combine(MERGE_CONTAMINATION_METRICS.out.metrics, by: 0)
    )

    emit:
    fastqs   = FILTER_FASTQ_BY_CONTAMINATION.out.filtered_fastqs  // tuple(sample_id, chunk_id, filtered_r1, filtered_r2)
    metrics  = MERGE_CONTAMINATION_METRICS.out.metrics             // tuple(sample_id, merged_contamination_metrics.csv)
}
