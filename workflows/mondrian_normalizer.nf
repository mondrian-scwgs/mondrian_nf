nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('reads')
assert_required_param('metrics')
assert_required_param('normal_copy')
assert_required_param('bam')
assert_required_param('sample_id')

reads = params.reads
metrics = params.metrics
normal_copy = params.normal_copy
bam = params.bam
sample_id = params.sample_id

if(params.qc_only){
    qc_only = params.qc_only
} else {
    qc_only = false
}

if(params.aneuploidy_score_threshold){
    aneuploidy_score_threshold = params.aneuploidy_score_threshold
} else {
    aneuploidy_score_threshold = 0.005
}

if(params.ploidy_threshold){
    ploidy_threshold = params.ploidy_threshold
} else {
    ploidy_threshold = 2.5
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_NORMALIZER         } from '../subworkflows/local/normalizer'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_NORMALIZER_PIPELINE{

    bams = MONDRIAN_NORMALIZER(
        reads,
        metrics,
        normal_copy,
        bam,
        qc_only,
        aneuploidy_score_threshold,
        ploidy_threshold,
        sample_id
    )

}
