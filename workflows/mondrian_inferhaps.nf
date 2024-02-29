nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param, param_name){
    if(! param){
        exit 1, param_name +' not specified. Please provide --${param_name} <value> !'
    }
}
assert_required_param(params.bam, 'bam')
assert_required_param(params.reference_fasta, 'reference_fasta')
assert_required_param(params.chromosome_references, 'chromosome_references')
assert_required_param(params.phased_chromosomes, 'phased_chromosomes')
assert_required_param(params.phased_chromosome_x, 'phased_chromosome_x')
assert_required_param(params.is_female, 'is_female')
// assert_required_param(params.sample_id, 'sample_id')


bam = file(params.bam)
reference_fasta = file(params.reference_fasta)
chromosome_references = file(params.chromosome_references)
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
        is_female,
        sample_id
    )

}
