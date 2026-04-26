nextflow.enable.dsl=2

include { ADD_CB_TO_FASTQ } from '../../modules/local/add_cb_to_fastq'
include { CONCAT_FASTQS } from '../../modules/local/concat_fastqs'
include { CONTAMINATION_FILTER } from '../../subworkflows/local/contamination_filter'
include { FASTP } from '../../modules/local/fastp'
include { BWA_MEM_BULK } from '../../modules/local/bwa_mem_bulk'
include { SAMTOOLS_SORT_FIXMATE } from '../../modules/local/samtools_sort_fixmate'
include { SAMTOOLS_MARKDUP_BARCODE } from '../../modules/local/samtools_markdup_barcode'
include { EXTRACT_PER_CELL_METRICS } from '../../modules/local/extract_per_cell_metrics'
include { GENERATE_RG_HEADER } from '../../modules/local/generate_rg_header'


workflow BULK_ALIGNMENT {

    take:
        fastqs_ch                    // Channel of [cell_id, readgroup_id, fastq1, fastq2]
        samplesheet                  // Path to extended samplesheet CSV
        primary_reference
        primary_reference_name
        sample_id

    main:

        // Step 0: Generate @RG header lines from samplesheet
        GENERATE_RG_HEADER(samplesheet, sample_id)

        // Step 1: Add CB and RG tags to each cell's FASTQs (parallel per cell)
        ADD_CB_TO_FASTQ(fastqs_ch)

        // Step 2: Collect all tagged FASTQs and concatenate
        // CONCAT_FASTQS sorts by filename before cat, guaranteeing R1/R2 pairs are matched
        tagged_r1 = ADD_CB_TO_FASTQ.out.map { cell_id, rg_id, r1, r2 -> r1 }.collect()
        tagged_r2 = ADD_CB_TO_FASTQ.out.map { cell_id, rg_id, r1, r2 -> r2 }.collect()
        CONCAT_FASTQS(tagged_r1, tagged_r2, sample_id)

        // Step 2.5: Optional contamination filtering
        if (params.run_contamination_filter) {
            // Validate supplementary references and names are provided and match
            if (!params.supplementary_references || params.supplementary_references.size() == 0) {
                error("run_contamination_filter is enabled but supplementary_references is empty. Provide reference genomes for contamination screening.")
            }
            if (!params.supplementary_reference_names || params.supplementary_reference_names.size() == 0) {
                error("run_contamination_filter is enabled but supplementary_reference_names is empty. Provide names for supplementary references.")
            }
            if (params.supplementary_references.size() != params.supplementary_reference_names.size()) {
                error("Number of supplementary_references (${params.supplementary_references.size()}) does not match supplementary_reference_names (${params.supplementary_reference_names.size()})")
            }

            CONTAMINATION_FILTER(
                CONCAT_FASTQS.out,
                file(primary_reference),
                primary_reference_name,
                params.supplementary_references,
                params.supplementary_reference_names,
                params.contamination_threshold ?: 0.05
            )
            // CONTAMINATION_FILTER.out.fastqs: tuple(sample_id, filtered_r1, filtered_r2)
            fastp_input = CONTAMINATION_FILTER.out.fastqs
            contamination_metrics = CONTAMINATION_FILTER.out.metrics
        } else {
            // Tuple flows intact: tuple(sample_id, merged_R1, merged_R2)
            fastp_input = CONCAT_FASTQS.out
            contamination_metrics = Channel.empty()
        }

        // Step 3: Adapter trimming with fastp
        FASTP(fastp_input)

        // Step 4: BWA alignment with -C flag to preserve CB/RG tags and -H for @RG header
        BWA_MEM_BULK(
            FASTP.out.trimmed_fastqs,
            primary_reference,
            file(primary_reference + '.fai'),
            BwaUtils.getBwaIndices(primary_reference).collect { file(it) },
            GENERATE_RG_HEADER.out.header
        )

        // Step 5: Sort and prepare for duplicate marking (fixmate)
        SAMTOOLS_SORT_FIXMATE(BWA_MEM_BULK.out)

        // Step 6: Mark duplicates with barcode awareness
        SAMTOOLS_MARKDUP_BARCODE(SAMTOOLS_SORT_FIXMATE.out)

        // Step 7: Extract per-cell metrics from the merged BAM
        EXTRACT_PER_CELL_METRICS(SAMTOOLS_MARKDUP_BARCODE.out.bam)

    emit:
        bam = SAMTOOLS_MARKDUP_BARCODE.out.bam
        markdup_metrics = SAMTOOLS_MARKDUP_BARCODE.out.metrics
        per_cell_metrics = EXTRACT_PER_CELL_METRICS.out.metrics
        fastp_reports = FASTP.out.reports
        contamination_metrics = contamination_metrics  // Optional: empty if not run
}
