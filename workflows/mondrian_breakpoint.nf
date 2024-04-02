nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param, param_name){
    if(! param){
        exit 1, param_name +' not specified. Please provide --${param_name} <value> !'
    }
}

assert_required_param(params.normal, 'normal')
assert_required_param(params.tumor, 'tumor')
assert_required_param(params.metadata, 'metadata')
assert_required_param(params.chromosomes, 'chromosomes')
assert_required_param(params.reference, 'reference')
assert_required_param(params.reference_gtf, 'reference_gtf')
assert_required_param(params.reference_dgv, 'reference_dgv')
assert_required_param(params.repeats_satellite_regions, 'repeats_satellite_regions')
assert_required_param(params.sample_id, 'sample_id')
assert_required_param(params.numcores, 'numcores')

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
    blacklist = tuple(false, file("$baseDir/assets/dummy_file.txt"))
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
