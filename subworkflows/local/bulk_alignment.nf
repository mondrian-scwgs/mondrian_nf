nextflow.enable.dsl=2

include { ADD_CB_TO_FASTQ } from '../../modules/local/add_cb_to_fastq'
include { CONCAT_FASTQS } from '../../modules/local/concat_fastqs'
include { FASTP } from '../../modules/local/fastp'
include { BWA_MEM_BULK } from '../../modules/local/bwa_mem_bulk'
include { SAMTOOLS_SORT_FIXMATE } from '../../modules/local/samtools_sort_fixmate'
include { SAMTOOLS_MARKDUP_BARCODE } from '../../modules/local/samtools_markdup_barcode'
include { EXTRACT_PER_CELL_METRICS } from '../../modules/local/extract_per_cell_metrics'
include { GENERATE_RG_HEADER } from '../../modules/local/generate_rg_header'


workflow BULK_ALIGNMENT {

    take:
        fastqs_ch                    // Channel of [cell_id, lane_id, flowcell_id, sample_id, library_id, fastq1, fastq2]
        samplesheet                  // Path to extended samplesheet CSV
        primary_reference
        primary_reference_version
        primary_reference_name
        sample_id

    main:

        // Step 0: Generate @RG header from samplesheet
        GENERATE_RG_HEADER(samplesheet, sample_id)

        // Step 1: Add CB and RG tags to each cell's FASTQs (parallel per cell)
        ADD_CB_TO_FASTQ(fastqs_ch)

        // Step 2: Collect all tagged FASTQs and concatenate
        tagged_r1 = ADD_CB_TO_FASTQ.out.map { it[1] }.collect()
        tagged_r2 = ADD_CB_TO_FASTQ.out.map { it[2] }.collect()
        CONCAT_FASTQS(tagged_r1, tagged_r2, sample_id)

        // Step 3: Adapter trimming with fastp
        FASTP(CONCAT_FASTQS.out)

        // Step 4: BWA alignment with -C flag to preserve CB/RG tags and -H for @RG header
        BWA_MEM_BULK(
            FASTP.out.trimmed_fastqs,
            primary_reference,
            file(primary_reference + '.fai'),
            file(primary_reference + '.amb'),
            file(primary_reference + '.ann'),
            file(primary_reference + '.bwt'),
            file(primary_reference + '.pac'),
            file(primary_reference + '.sa'),
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
}
