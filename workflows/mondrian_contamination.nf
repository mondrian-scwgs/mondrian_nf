nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('bam_files')
assert_required_param('kraken_db')
assert_required_param('sample_id')
assert_required_param('hmmcopy_metrics_file')
assert_required_param('ncbi_taxonomy_database')

bam_files = Channel.fromPath(params.bam_files)
kraken_db = file(params.kraken_db)
sample_id = params.sample_id
hmmcopy_metrics_file = file(params.hmmcopy_metrics_file)
ncbi_taxonomy_database = file(params.ncbi_taxonomy_database)

// Optional parameters with defaults
kraken_threads = params.kraken_threads ?: 4
min_percent_aggregate = params.min_percent_aggregate ?: 0.0
min_percent_show = params.min_percent_show ?: 2.0
min_num_taxa_condense = params.min_num_taxa_condense ?: 25

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_CONTAMINATION } from '../subworkflows/local/contamination'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_CONTAMINATION_PIPELINE{

    MONDRIAN_CONTAMINATION(
        bam_files,
        kraken_db,
        kraken_threads,
        sample_id,
        hmmcopy_metrics_file,
        ncbi_taxonomy_database,
        min_percent_aggregate,
        min_percent_show,
        min_num_taxa_condense
    )

}
