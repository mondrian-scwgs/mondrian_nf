nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('bam')
assert_required_param('reference_fasta')
assert_required_param('chromosome_references')
assert_required_param('phased_chromosomes')
assert_required_param('phased_chromosome_x')
assert_required_param('is_female')
assert_required_param('sample_id')
assert_required_param('metadata_input')


bam = file(params.bam)
reference_fasta = file(params.reference_fasta)
chromosome_references = file(params.chromosome_references)
metadata_input = file(params.metadata_input)
phased_chromosomes = params.phased_chromosomes
phased_chromosome_x = params.phased_chromosome_x
is_female = params.is_female
sample_id = params.sample_id
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_INFERHAPS         } from '../subworkflows/local/inferhaps'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_INFERHAPS_PIPELINE{

    MONDRIAN_INFERHAPS(
        bam,
        reference_fasta,
        chromosome_references,
        phased_chromosomes,
        phased_chromosome_x,
        metadata_input,
        is_female,
        sample_id
    )

}
