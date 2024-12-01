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
assert_required_param('secondary_reference_1')
assert_required_param('secondary_reference_1_version')
assert_required_param('secondary_reference_1_name')
assert_required_param('gc_wig')
assert_required_param('map_wig')
assert_required_param('quality_classifier_training_data')
assert_required_param('repeats_satellite_regions')
assert_required_param('chromosomes')
assert_required_param('fastqs')
assert_required_param('sample_id')

primary_reference = file(params.primary_reference)
primary_reference_version = params.primary_reference_version
primary_reference_name = params.primary_reference_name
secondary_reference_1 = file(params.secondary_reference_1)
secondary_reference_1_version = params.secondary_reference_1_version
secondary_reference_1_name = params.secondary_reference_1_name
gc_wig = file(params.gc_wig)
map_wig = file(params.map_wig)
quality_classifier_training_data = file(params.quality_classifier_training_data)
repeats_satellite_regions = file(params.repeats_satellite_regions)
chromosomes = params.chromosomes
fastqs = file(params.fastqs)
sample_id = params.sample_id



if(params.secondary_reference_2){
    secondary_reference_2 = file(params.secondary_reference_2)
    secondary_reference_2_version = params.secondary_reference_2_version
    secondary_reference_2_name = params.secondary_reference_2_name
} else {
    secondary_reference_2 = file("$baseDir/docs/assets/dummy_file.txt")
    secondary_reference_2_version = null
    secondary_reference_2_name = null
}



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MONDRIAN_QC         } from '../subworkflows/local/qc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MONDRIAN_QC_PIPELINE{

    MONDRIAN_QC(
        fastqs,
        primary_reference,
        primary_reference_version,
        primary_reference_name,
        secondary_reference_1,
        secondary_reference_1_version,
        secondary_reference_1_name,
        secondary_reference_2,
        secondary_reference_2_version,
        secondary_reference_2_name,
        gc_wig,
        map_wig,
        quality_classifier_training_data,
        repeats_satellite_regions,
        chromosomes,
        sample_id
    )

}
