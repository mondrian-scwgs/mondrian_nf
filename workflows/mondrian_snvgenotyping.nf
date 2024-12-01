nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param_name){
    if(!params.containsKey(param_name)){
        exit 1, "${param_name} not specified. Please provide --${param_name} <value>!"
    }
}

assert_required_param('vcf_files')
assert_required_param('bam_file')
assert_required_param('reference_fasta')

if(params.blacklist){
    blacklist = tuple(true, file(params.blacklist))
} else {
    blacklist = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}
if(params.barcodes){
    cell_barcodes = tuple(true, file(params.barcodes))
} else {
    cell_barcodes = tuple(false, file("$baseDir/docs/assets/dummy_file.txt"))
}

if(params.numlines){
    numlines = params.numlines
} else {
    numlines = 1000
}


vcf_files = Channel.fromPath(params.vcf_files)
bam_file = file(params.bam_file)
reference_fasta = file(params.reference_fasta)
numcores = params.numcores
sample_id = params.sample_id
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_SNVGENOTYPING         } from '../subworkflows/local/snvgenotyping'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_SNVGENOTYPING_PIPELINE{

    MONDRIAN_SNVGENOTYPING(
        bam_file,
        vcf_files,
        blacklist,
        cell_barcodes,
        reference_fasta,
        numlines,
        numcores,
        sample_id
    )

}
