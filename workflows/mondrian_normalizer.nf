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
assert_required_param('bam')
assert_required_param('chromosomes')
assert_required_param('sample_id')

reads = params.reads
metrics = params.metrics
bam = params.bam
chromosomes = params.chromosomes
sample_id = params.sample_id

if(params.blacklist){
    blacklist = tuple(true, file(params.blacklist))
} else {
    blacklist = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}

if(params.qc_only){
    qc_only = params.qc_only
} else {
    qc_only = false
}

if(params.relative_aneuploidy_threshold){
    relative_aneuploidy_threshold = params.relative_aneuploidy_threshold
} else {
    relative_aneuploidy_threshold = 0.05
}

if(params.ploidy_threshold){
    ploidy_threshold = params.ploidy_threshold
} else {
    ploidy_threshold = 2.5
}

if(params.allowed_aneuploidy_score){
    allowed_aneuploidy_score = params.allowed_aneuploidy_score
} else {
    allowed_aneuploidy_score = 0.005
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
        bam,
        blacklist,
        qc_only,
        chromosomes,
        relative_aneuploidy_threshold,
        ploidy_threshold,
        allowed_aneuploidy_score,
        sample_id
    )

}
