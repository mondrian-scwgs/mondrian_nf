nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('bam_file')
assert_required_param('cell_ids')
assert_required_param('kraken_db')
assert_required_param('sample_id')

bam_file = file(params.bam_file)
cell_ids = params.cell_ids
kraken_db = file(params.kraken_db)
sample_id = params.sample_id

// Optional parameters with defaults
kraken_threads = params.kraken_threads ?: 4

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
        bam_file,
        cell_ids,
        kraken_db,
        kraken_threads,
        sample_id
    )

    // Output results for monitoring
    MONDRIAN_CONTAMINATION.out.kraken_results.view { cell_id, output_file, report_file ->
        "Completed contamination analysis for cell: ${cell_id}"
    }

}
