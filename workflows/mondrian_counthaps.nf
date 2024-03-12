nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param, param_name){
    if(! param){
        exit 1, param_name +' not specified. Please provide --${param_name} <value> !'
    }
}
assert_required_param(params.tumor_bam, 'tumor_bam')
assert_required_param(params.haplotypes_csv, 'haplotypes_csv')
assert_required_param(params.chromosomes, 'chromosomes')
assert_required_param(params.snp_positions, 'snp_positions')
assert_required_param(params.reference_fasta, 'reference_fasta')
assert_required_param(params.gap_table, 'gap_table')

tumor_bam = file(params.tumor_bam)
haplotypes_csv = file(params.haplotypes_csv)
snp_positions = file(params.snp_positions)
reference_fasta = file(params.reference_fasta)
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
        gap_table,
        chromosomes,
        numcores,
        sample_id
    )

}
