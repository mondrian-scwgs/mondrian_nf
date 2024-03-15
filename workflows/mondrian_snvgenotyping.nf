nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param, param_name){
    if(! param){
        exit 1, param_name +' not specified. Please provide --${param_name} <value> !'
    }
}
assert_required_param(params.vcf_files, 'vcf_files')
assert_required_param(params.bam_file, 'bam_file')
assert_required_param(params.metadata_input, 'metadata_input')
assert_required_param(params.reference_fasta, 'reference_fasta')

if(params.blacklist){
    blacklist = tuple(true, file(params.blacklist))
} else {
    blacklist = tuple(false, file("$baseDir/assets/dummy_file.txt"))
}
if(params.barcodes){
    cell_barcodes = tuple(true, file(params.barcodes))
} else {
    cell_barcodes = tuple(false, file("$baseDir/assets/dummy_file.txt"))
}

vcf_files = Channel.fromPath(params.vcf_files)
bam_file = file(params.bam_file)
reference_fasta = file(params.reference_fasta)
metadata_input = file(params.metadata_input)
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
        metadata_input,
        numcores,
        sample_id
    )

}
