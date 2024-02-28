nextflow.enable.dsl=2

include { CONCATCSV as CONCATREADS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATSEGMENTS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATPARAMS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATMETRICS } from '../../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATGCMETRICS } from '../../modules/local/csverve_concat_csv'
include { BUILDTAR as HMMTAR } from '../../modules/local/tar'
include { BUILDTAR as ALIGNTAR } from '../../modules/local/tar'
include { ALIGN } from '../../modules/local/align'
include { CELLCYCLECLASSIFIER } from '../../modules/local/cell_cycle_classifier'
include { ADDCLUSTERINGORDER } from '../../modules/local/clustering_order'
include { PLOTHEATMAP } from '../../modules/local/heatmap'
include { HMMCOPY } from '../../modules/local/hmmcopy'
include { HTMLREPORT } from '../../modules/local/html_report'
include { BAMMERGE } from '../../modules/local/merge_bams'
include { QCMETADATA } from '../../modules/local/qc_metadata'
include { VALIDATEQCINPUTS } from '../../modules/local/validate_qc_inputs'


workflow MONDRIAN_QC{

    take:
        fastqs
        metadata_yaml
        human_reference
        human_reference_version
        mouse_reference
        mouse_reference_version
        salmon_reference
        salmon_reference_version
        gc_wig
        map_wig
        quality_classifier_training_data
        repeats_satellite_regions
        chromosomes
        sample_id

    main:

    VALIDATEQCINPUTS(fastqs, metadata_yaml)
    fastqs_data = Channel
               .fromPath(fastqs)
               .splitCsv(header:true, sep:',')

    lanes = fastqs_data.map{row -> tuple(row.cellid, row.laneid)}.groupTuple(by: 0)
    flowcells = fastqs_data.map{row -> tuple(row.cellid, row.flowcellid)}.groupTuple(by: 0)
    lanes1 = fastqs_data.map{row -> tuple(row.cellid, row.fastq1)}.groupTuple(by: 0)
    lanes2 = fastqs_data.map{row -> tuple(row.cellid, row.fastq2)}.groupTuple(by: 0)

    fastqs = lanes.join(flowcells).join(lanes1).join(lanes2).map{
        row -> tuple(
            row[0], row[1], row[2], row[3], row[4],
                       human_reference, human_reference_version,
                       human_reference+'.fai', human_reference+'.amb', human_reference+'.ann',
                       human_reference+'.bwt', human_reference+'.pac', human_reference+'.sa',
                       mouse_reference, mouse_reference_version,
                       mouse_reference+'.fai', mouse_reference+'.amb', mouse_reference+'.ann',
                       mouse_reference+'.bwt', mouse_reference+'.pac', mouse_reference+'.sa',
                       salmon_reference, salmon_reference_version,
                       salmon_reference+'.fai', salmon_reference+'.amb', salmon_reference+'.ann',
                       salmon_reference+'.bwt', salmon_reference+'.pac', salmon_reference+'.sa',
                       metadata_yaml
        )
    }

    ALIGN(fastqs)

    CONCATGCMETRICS(ALIGN.out.collect{it[5]}, ALIGN.out.collect{it[6]}, sample_id+'_gc_metrics', true)

    ALIGNTAR(ALIGN.out.collect{it[7]}, sample_id+'_alignment_data')



    hmm_input = ALIGN.out.map {
        it -> tuple(
            it[0],it[1],it[2], gc_wig, map_wig,
            human_reference, human_reference+'.fai',
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

    BAMMERGE(
      ALIGN.out.collect{it[0]}, ALIGN.out.collect{it[1]}, ALIGN.out.collect{it[2]},
      human_reference, human_reference + '.fai',
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

    QCMETADATA(
    tuple(
        BAMMERGE.out.bam, BAMMERGE.out.bai,
        BAMMERGE.out.contaminated_bam, BAMMERGE.out.contaminated_bai,
        BAMMERGE.out.control_bam, BAMMERGE.out.control_bai,
        CONCATGCMETRICS.out.csv, CONCATGCMETRICS.out.yaml,
        ADDCLUSTERINGORDER.out.csv, ADDCLUSTERINGORDER.out.yaml,
        CONCATPARAMS.out.csv, CONCATPARAMS.out.yaml,
        CONCATSEGMENTS.out.csv, CONCATSEGMENTS.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
        PLOTHEATMAP.out.pdf, HTMLREPORT.out.html,
        ALIGNTAR.out.tar, HMMTAR.out.tar,
        VALIDATEQCINPUTS.out.metadata
    )
    )

}
