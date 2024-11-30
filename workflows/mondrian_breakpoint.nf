nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('normal')
assert_required_param('tumor')
assert_required_param('metadata')
assert_required_param('chromosomes')
assert_required_param('reference')
assert_required_param('reference_gtf')
assert_required_param('reference_dgv')
assert_required_param('repeats_satellite_regions')
assert_required_param('sample_id')
assert_required_param('numcores')

normal = params.normal
tumor = params.tumor
metadata = params.metadata
chromosomes = params.chromosomes
reference = params.reference
reference_dgv = params.reference_dgv
reference_gtf = params.reference_gtf
repeats = params.repeats_satellite_regions
sample_id = params.sample_id
numcores = params.numcores

if(params.blacklist){
    blacklist = tuple(true, file(params.blacklist))
} else {
    blacklist = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}

jvm_heap_gb = params.jvm_heap_gb ? jvm_heap_gb : 10

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_BREAKPOINT         } from '../subworkflows/local/breakpoint'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_BREAKPOINT_PIPELINE{

    MONDRIAN_BREAKPOINT(
        normal,
        tumor,
        metadata,
        chromosomes,
        reference,
        reference_gtf,
        reference_dgv,
        repeats,
        blacklist,
        sample_id,
        numcores,
        jvm_heap_gb
    )

}
