nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('bams')
assert_required_param('metrics')
assert_required_param('reference_fasta')
assert_required_param('gc_wig')
assert_required_param('map_wig')
assert_required_param('quality_classifier_training_data')
assert_required_param('repeats_satellite_regions')
assert_required_param('chromosomes')
assert_required_param('sample_id')

bams = params.bams instanceof List ? params.bams : params.bams.tokenize(',')
metrics = file(params.metrics)
metrics_yaml = file(params.metrics + '.yaml')
reference_fasta = file(params.reference_fasta)
gc_wig = file(params.gc_wig)
map_wig = file(params.map_wig)
quality_classifier_training_data = file(params.quality_classifier_training_data)
repeats_satellite_regions = file(params.repeats_satellite_regions)
chromosomes = params.chromosomes
sample_id = params.sample_id



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { CONCATCSV as CONCATREADS    } from '../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATSEGMENTS } from '../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATPARAMS   } from '../modules/local/csverve_concat_csv'
include { CONCATCSV as CONCATMETRICS  } from '../modules/local/csverve_concat_csv'
include { BUILDTAR as HMMTAR          } from '../modules/local/tar'
include { SPLIT_BULK_BAM              } from '../modules/local/split_bulk_bam'
include { SAMTOOLS_INDEX              } from '../modules/local/samtools_index'
include { CELLCYCLECLASSIFIER         } from '../modules/local/cell_cycle_classifier'
include { ADDCLUSTERINGORDER          } from '../modules/local/clustering_order'
include { PLOTHEATMAP                 } from '../modules/local/heatmap'
include { HMMCOPY                     } from '../modules/local/hmmcopy'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// --bams accepts a comma-separated string on the command line:
//   --bams "/path/to/a.bam,/path/to/b.bam"
// or a list in a params YAML/JSON file:
//   bams:
//     - /path/to/a.bam
//     - /path/to/b.bam

workflow MONDRIAN_HMMCOPY_PIPELINE{

    main:

    bams_ch = Channel.fromList(bams).map { b -> file(b) }

    // Split each bulk BAM into per-cell BAMs (one BAM per CB tag)
    SPLIT_BULK_BAM(bams_ch)

    // Flatten: per-process list of cell BAMs -> individual (cell_id, bam) tuples
    split_cells_ch = SPLIT_BULK_BAM.out.bams
        .flatMap { bam_list ->
            def bams = bam_list instanceof List ? bam_list : [bam_list]
            bams.collect { b -> [b.baseName, b] }
        }

    // Index each per-cell BAM
    SAMTOOLS_INDEX(split_cells_ch)

    // Build HMMCOPY input
    hmm_input = SAMTOOLS_INDEX.out.indexed
        .map { cell_id, bam, bai ->
            tuple(
                cell_id, bam, bai,
                gc_wig, map_wig,
                reference_fasta, reference_fasta + '.fai',
                metrics, metrics_yaml,
                repeats_satellite_regions, quality_classifier_training_data,
                chromosomes, "0.9"
            )
        }

    HMMCOPY(hmm_input)

    HMMTAR(HMMCOPY.out.collect{it[9]}, sample_id + '_hmmcopy_data')

    CONCATREADS(HMMCOPY.out.collect{it[1]}, HMMCOPY.out.collect{it[2]}, sample_id + '_hmmcopy_reads', false)
    CONCATMETRICS(HMMCOPY.out.collect{it[3]}, HMMCOPY.out.collect{it[4]}, sample_id + '_metrics', false)
    CONCATPARAMS(HMMCOPY.out.collect{it[5]}, HMMCOPY.out.collect{it[6]}, sample_id + '_hmmcopy_params', false)
    CONCATSEGMENTS(HMMCOPY.out.collect{it[7]}, HMMCOPY.out.collect{it[8]}, sample_id + '_hmmcopy_segments', false)

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

}
