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
assert_required_param('reference_dict')
assert_required_param('panel_of_normals')
assert_required_param('gnomad')
assert_required_param('vep_ref')
assert_required_param('vep_fasta_suffix')
assert_required_param('ncbi_build')
assert_required_param('cache_version')
assert_required_param('species')
assert_required_param('sample_id')
assert_required_param('numcores')


normal = params.normal
tumor = params.tumor
metadata = params.metadata
chromosomes = params.chromosomes
reference = params.reference
reference_dict = params.reference_dict
panel_of_normals = params.panel_of_normals
gnomad = params.gnomad
vep_ref = params.vep_ref
vep_fasta_suffix = params.vep_fasta_suffix
ncbi_build = params.ncbi_build
cache_version = params.cache_version
species = params.species
sample_id = params.sample_id
numcores = params.numcores

maxcoverage = params.maxcoverage ? maxcoverage : 10000


if(params.variants_for_contamination){
    variants_for_contamination = tuple(true, file(params.variants_for_contamination))
} else {
    variants_for_contamination = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}

if(params.realignment_index_bundle){
    realignment_index_bundle = tuple(true, file(params.realignment_index_bundle))
} else {
    realignment_index_bundle = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_VARIANT         } from '../subworkflows/local/variant'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_VARIANT_PIPELINE{

    MONDRIAN_VARIANT(
        normal,
        tumor,
        metadata,
        chromosomes,
        reference,
        reference_dict,
        panel_of_normals,
        variants_for_contamination,
        gnomad,
        realignment_index_bundle,
        vep_ref,
        vep_fasta_suffix,
        ncbi_build,
        cache_version,
        species,
        sample_id,
        numcores,
        maxcoverage
    )
}
