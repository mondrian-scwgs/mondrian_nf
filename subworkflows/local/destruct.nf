import groovy.json.JsonOutput

nextflow.enable.dsl=2

include { DESTRUCT } from '../../modules/local/destruct'
include { EXTRACTSOMATIC } from '../../modules/local/destruct_extract_somatic'
include { EXTRACTCOUNTS } from '../../modules/local/destruct_extract_counts'
include { DESTRUCT_TO_VCF } from '../../modules/local/destruct_csv_to_vcf'


process WRITEMETADATA {
    time '1h'
    cpus 1
    memory '1 GB'
    label 'process_low'

    input:
        val metadata
        path destruct_breakpoints
        path destruct_libraries
        path destruct_reads
        path destruct_somatic_breakpoints
        path destruct_somatic_library
        path destruct_vcf
        path destruct_vcf_tbi
        path destruct_counts
        path destruct_counts_yaml

    output:
        path 'metadata.yaml'

    script:
        def output_metadata = [
            files: [
                (destruct_breakpoints.name): [results_type: 'destruct_breakpoints'],
                (destruct_libraries.name): [results_type: 'destruct_libraries'],
                (destruct_reads.name): [results_type: 'destruct_reads'],
                (destruct_somatic_breakpoints.name): [results_type: 'destruct_somatic_breakpoints'],
                (destruct_somatic_library.name): [results_type: 'destruct_somatic_library'],
                (destruct_vcf.name): [results_type: 'destruct_vcf'],
                (destruct_vcf_tbi.name): [results_type: 'destruct_vcf'],
                (destruct_counts.name): [results_type: 'destruct_counts'],
                (destruct_counts_yaml.name): [results_type: 'destruct_counts'],
            ]
        ]
        output_metadata['meta'] = metadata

        output_metadata_json = JsonOutput.toJson(output_metadata)

        """
        write_yaml_from_json.py '${output_metadata_json}' metadata.yaml
        """
}


workflow MONDRIAN_DESTRUCT{

    take:
        normal
        tumor
        metadata
        chromosomes
        reference
        reference_gtf
        reference_dgv
        repeats
        blacklist
        sample_id
        numcores

    main:
        destruct = DESTRUCT(
            normal, normal+'.bai', tumor, tumor+'.bai', reference, reference+'.fai', reference+'.1.ebwt', reference+'.2.ebwt',
            reference+'.3.ebwt', reference+'.4.ebwt', reference+'.rev.1.ebwt', reference+'.rev.2.ebwt', reference_dgv,
            reference_gtf, repeats, sample_id+'_destruct', numcores
        )
        extract_somatic = EXTRACTSOMATIC(destruct.table, destruct.library, sample_id+'_extract_somatic')
        destruct_vcf = DESTRUCT_TO_VCF(extract_somatic.breakpoints, reference, sample_id, sample_id+'_destruct')
        destruct_counts = EXTRACTCOUNTS(destruct.read, sample_id+'_counts')

        WRITEMETADATA(
            metadata,
            destruct.table,
            destruct.library,
            destruct.read,
            extract_somatic.breakpoints,
            extract_somatic.library,
            destruct_vcf.vcf,
            destruct_vcf.tbi,
            destruct_counts.csv,
            destruct_counts.yaml,
        )
}
