nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('tumor_bam')
assert_required_param('haplotypes_csv')
assert_required_param('chromosomes')
assert_required_param('snp_positions')
assert_required_param('reference_fasta')
assert_required_param('gap_table')
assert_required_param('metadata_input')

tumor_bam = file(params.tumor_bam)
haplotypes_csv = file(params.haplotypes_csv)
snp_positions = file(params.snp_positions)
reference_fasta = file(params.reference_fasta)
metadata_input = file(params.metadata_input)
gap_table = file(params.gap_table)
chromosomes = params.chromosomes
numcores = params.numcores
sample_id = params.sample_id
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_COUNTHAPS         } from '../subworkflows/local/counthaps'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_COUNTHAPS_PIPELINE{

    bams = MONDRIAN_COUNTHAPS(
        tumor_bam,
        haplotypes_csv,
        snp_positions,
        reference_fasta,
        metadata_input,
        gap_table,
        chromosomes,
        numcores,
        sample_id
    )

}
