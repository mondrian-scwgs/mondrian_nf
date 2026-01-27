nextflow.enable.dsl=2

include { CONCATCSV as CONCATREADS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATSEGMENTS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATPARAMS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATMETRICS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATGCMETRICS } from '../../modules/local/csverve_concat_csv'
include { BUILDTAR as HMMTAR } from '../../modules/local/tar'
include { BUILDTAR as ALIGNTAR } from '../../modules/local/tar'
include { ALIGN as ALIGN_SMALL } from '../../modules/local/align'
include { ALIGN as ALIGN_LARGE } from '../../modules/local/align'
include { CELLCYCLECLASSIFIER } from '../../modules/local/cell_cycle_classifier'
include { ADDCLUSTERINGORDER } from '../../modules/local/clustering_order'
include { PLOTHEATMAP } from '../../modules/local/heatmap'
include { HMMCOPY } from '../../modules/local/hmmcopy'
include { HTMLREPORT } from '../../modules/local/html_report'
include { BAMMERGECELLS } from '../../modules/local/merge_cells'


workflow MONDRIAN_QC{

    take:
        fastqs
        metadata_yaml
        primary_reference
        primary_reference_version
        primary_reference_name
        secondary_reference_1
        secondary_reference_1_version
        secondary_reference_1_name
        secondary_reference_2
        secondary_reference_2_version
        secondary_reference_2_name
        gc_wig
        map_wig
        quality_classifier_training_data
        repeats_satellite_regions
        chromosomes
        sample_id

    main:

    fastqs_data = Channel
               .fromPath(fastqs)
               .splitCsv(header:true, sep:',')

    lanes = fastqs_data.map{row -> tuple(row.cellid, row.laneid)}.groupTuple(by: 0)
    flowcells = fastqs_data.map{row -> tuple(row.cellid, row.flowcellid)}.groupTuple(by: 0)
    lanes1 = fastqs_data.map{row -> tuple(row.cellid, row.fastq1)}.groupTuple(by: 0)
    lanes2 = fastqs_data.map{row -> tuple(row.cellid, row.fastq2)}.groupTuple(by: 0)

    fastqs_with_size = lanes.join(flowcells).join(lanes1).join(lanes2).map{
        row ->
            def total_fastq_size = row[3].collect { file(it).size() }.sum() + row[4].collect { file(it).size() }.sum()
            tuple(
            row[0], row[1], row[2], row[3], row[4],
            total_fastq_size,
                       primary_reference, primary_reference_version, primary_reference_name,
                       primary_reference+'.fai', primary_reference+'.amb', primary_reference+'.ann',
                       primary_reference+'.bwt', primary_reference+'.pac', primary_reference+'.sa',
                       secondary_reference_1, secondary_reference_1_version, secondary_reference_1_name,
                       secondary_reference_1+'.fai', secondary_reference_1+'.amb', secondary_reference_1+'.ann',
                       secondary_reference_1+'.bwt', secondary_reference_1+'.pac', secondary_reference_1+'.sa',
                       secondary_reference_2, secondary_reference_2_version, secondary_reference_2_name,
                       secondary_reference_2+'.fai', secondary_reference_2+'.amb', secondary_reference_2+'.ann',
                       secondary_reference_2+'.bwt', secondary_reference_2+'.pac', secondary_reference_2+'.sa',
                       metadata_yaml
        )
    }

    // Split into small and large based on total fastq size (1 GB threshold)
    fastqs_small = fastqs_with_size.filter { it[5] < 1_000_000_000 }.map {
        row -> tuple(
            row[0], row[1], row[2], row[3], row[4],
            row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14],
            row[15], row[16], row[17], row[18], row[19], row[20], row[21], row[22], row[23],
            row[24], row[25], row[26], row[27], row[28], row[29], row[30], row[31], row[32],
            row[33]
        )
    }
    fastqs_large = fastqs_with_size.filter { it[5] >= 1_000_000_000 }.map {
        row -> tuple(
            row[0], row[1], row[2], row[3], row[4],
            row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14],
            row[15], row[16], row[17], row[18], row[19], row[20], row[21], row[22], row[23],
            row[24], row[25], row[26], row[27], row[28], row[29], row[30], row[31], row[32],
            row[33]
        )
    }

    ALIGN_SMALL(fastqs_small)
    ALIGN_LARGE(fastqs_large)

    // Merge outputs from both processes
    align_out = ALIGN_SMALL.out.mix(ALIGN_LARGE.out)

    CONCATGCMETRICS(align_out.collect{it[5]}, align_out.collect{it[6]}, sample_id+'_gc_metrics', true)

    ALIGNTAR(align_out.collect{it[7]}, sample_id+'_alignment_data')



    hmm_input = align_out.map {
        it -> tuple(
            it[0],it[1],it[2], gc_wig, map_wig,
            primary_reference, primary_reference+'.fai',
            it[3],it[4],
            repeats_satellite_regions, quality_classifier_training_data,
            chromosomes, "0.9"
        )
    }

    HMMCOPY(hmm_input)

    HMMTAR(HMMCOPY.out.collect{it[9]}, sample_id+'_hmmcopy_data')

    CONCATREADS(HMMCOPY.out.collect{it[1]}, HMMCOPY.out.collect{it[2]}, sample_id+'_hmmcopy_reads', false)
    CONCATMETRICS(HMMCOPY.out.collect{it[3]}, HMMCOPY.out.collect{it[4]}, sample_id+'_metrics', false)
    CONCATPARAMS(HMMCOPY.out.collect{it[5]}, HMMCOPY.out.collect{it[6]}, sample_id+'_hmcopy_params', false)
    CONCATSEGMENTS(HMMCOPY.out.collect{it[7]}, HMMCOPY.out.collect{it[8]}, sample_id+'_hmmcopy_segments', false)

    BAMMERGECELLS(
      align_out.collect{it[0]}, align_out.collect{it[1]}, align_out.collect{it[2]},
      primary_reference, primary_reference + '.fai',
      CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
      sample_id
    )
    CELLCYCLECLASSIFIER(
        CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
    )

    ADDCLUSTERINGORDER(
        CELLCYCLECLASSIFIER.out.csv, CELLCYCLECLASSIFIER.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
        chromosomes, sample_id + '_metrics'
    )

    PLOTHEATMAP(
        CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
        chromosomes, sample_id + '_heatmap'
    )

    HTMLREPORT(
        CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
        CONCATGCMETRICS.out.csv, CONCATGCMETRICS.out.yaml,
        sample_id + '_qcreport'
    )
}
