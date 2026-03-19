nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('primary_reference')
assert_required_param('primary_reference_version')
assert_required_param('primary_reference_name')
assert_required_param('fastqs')
assert_required_param('sample_id')

primary_reference = file(params.primary_reference)
primary_reference_version = params.primary_reference_version
primary_reference_name = params.primary_reference_name
fastqs = file(params.fastqs)
sample_id = params.sample_id

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BULK_ALIGNMENT } from '../subworkflows/local/bulk_alignment'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MONDRIAN_BULK_ALIGNMENT_PIPELINE {

    // Parse extended samplesheet CSV to create channel with all metadata
    // Columns: cellid,laneid,flowcellid,sample_id,library_id,sequencing_centre,...,fastq1,fastq2
    fastqs_ch = Channel
        .fromPath(fastqs)
        .splitCsv(header:true, sep:',')
        .map { row -> tuple(
            row.cellid,
            row.laneid,
            row.flowcellid,
            row.sample_id,
            row.library_id,
            file(row.fastq1),
            file(row.fastq2)
        )}

    // Run bulk alignment workflow
    BULK_ALIGNMENT(
        fastqs_ch,
        fastqs,                      // Pass samplesheet path for RG header generation
        primary_reference,
        primary_reference_version,
        primary_reference_name,
        sample_id
    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DEFAULT ENTRY POINT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    MONDRIAN_BULK_ALIGNMENT_PIPELINE()
}
