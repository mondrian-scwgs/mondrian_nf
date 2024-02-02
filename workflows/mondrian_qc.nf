nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

def assert_required_param(param, param_name){
    if(! param){
        exit 1, '${param_name} not specified. Please provide --${param_name} <value> !'
    }
}
assert_required_param(params.human_reference, 'human_reference')
assert_required_param(params.human_reference_version, 'human_reference_version')
assert_required_param(params.mouse_reference, 'mouse_reference')
assert_required_param(params.mouse_reference_version, 'mouse_reference_version')
assert_required_param(params.salmon_reference, 'mouse_reference')
assert_required_param(params.salmon_reference_version, 'mouse_reference_version')
assert_required_param(params.gc_wig, 'gc_wig')
assert_required_param(params.map_wig, 'map_wig')
assert_required_param(params.quality_classifier_training_data, 'quality_classifier_training_data')
assert_required_param(params.repeats_satellite_regions, 'repeats_satellite_regions')
assert_required_param(params.chromosomes, 'chromosomes')
assert_required_param(params.fastqs, 'fastqs')
assert_required_param(params.metadata, 'metadata')

human_reference = file(params.human_reference)
human_reference_version = file(params.human_reference_version)
mouse_reference = file(params.mouse_reference)
mouse_reference_version = file(params.mouse_reference_version)
salmon_reference = file(params.salmon_reference)
salmon_reference_version = file(params.salmon_reference_version)
gc_wig = file(params.gc_wig)
map_wig = file(params.map_wig)
quality_classifier_training_data = file(params.quality_classifier_training_data)
repeats_satellite_regions = file(params.repeats_satellite_regions)
chromosomes = params.chromosomes
fastqs = file(params.fastqs)
metadata = file(params.metadata)
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
        metadata,
        human_reference,
        human_reference_version,
        mouse_reference,
        mouse_reference_version,
        salmon_reference,
        salmon_reference_version,
        gc_wig,
        map_wig,
        quality_classifier_training_data,
        repeats_satellite_regions,
        chromosomes
    )

}
