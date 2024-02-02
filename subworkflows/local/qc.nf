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

    main:

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

    CONCATGCMETRICS(ALIGN.out.collect{it[5]}, ALIGN.out.collect{it[6]}, true)

    ALIGNTAR(ALIGN.out.collect{it[7]})



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

    HMMTAR(HMMCOPY.out.collect{it[9]})

    CONCATREADS(HMMCOPY.out.collect{it[1]}, HMMCOPY.out.collect{it[2]}, false)
    CONCATMETRICS(HMMCOPY.out.collect{it[3]}, HMMCOPY.out.collect{it[4]}, false)
    CONCATPARAMS(HMMCOPY.out.collect{it[5]}, HMMCOPY.out.collect{it[6]}, false)
    CONCATSEGMENTS(HMMCOPY.out.collect{it[7]}, HMMCOPY.out.collect{it[8]}, false)

    BAMMERGE(
      ALIGN.out.collect{it[0]}, ALIGN.out.collect{it[1]}, ALIGN.out.collect{it[2]},
      human_reference, human_reference + '.fai',
      CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml
    )
    CELLCYCLECLASSIFIER(
        CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
    )

    ADDCLUSTERINGORDER(
        CELLCYCLECLASSIFIER.out.csv, CELLCYCLECLASSIFIER.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
        chromosomes
    )

    PLOTHEATMAP(
        CONCATMETRICS.out.csv, CONCATMETRICS.out.yaml,
        CONCATREADS.out.csv, CONCATREADS.out.yaml,
        chromosomes
    )

}
