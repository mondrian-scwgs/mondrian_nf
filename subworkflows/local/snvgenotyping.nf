import groovy.json.JsonOutput

nextflow.enable.dsl=2


include { MERGEVCFS } from '../../modules/local/merge_vcfs'
include { GENERATEBARCODES } from '../../modules/local/generate_barcodes'
include { REMOVEDUPLICATES } from '../../modules/local/vcf_remove_duplicates'
include { REMOVEBLACKLISTEDCALLS } from '../../modules/local/vcf_remove_blacklisted_calls'
include { SPLITVCFBYNUMLINES } from '../../modules/local/vcf_split_by_lines'
include { VARTRIX } from '../../modules/local/vartrix'
include { RECOPY } from '../../modules/local/recopy'
include { CONCATCSV } from '../../modules/local/csverve_concat_csv'
include { REGENERATEVARTRIXOUTPUTS } from '../../modules/local/regenerate_vartrix_outputs'
include { PYSAMGENOTYPER } from '../../modules/local/pysam_genotyper'


process WRITEMETADATA {
    time '1h'
    cpus 1
    memory '1 GB'
    label 'process_low'

    input:
        val metadata
        path vartrix_all_chroms_csv
        path vartrix_all_chroms_yaml
        path vartrix_outputs_barcodes
        path vartrix_outputs_variants
        path vartrix_outputs_ref_counts
        path vartrix_outputs_alt_counts
        path genotyper_csv
        path genotyper_yaml

    output:
        path 'metadata.yaml'

    script:
        def output_metadata = [
            files: [
                (vartrix_all_chroms_csv.name): [results_type: 'vartrix_all_chroms_csv', auxiliary: false],
                (vartrix_all_chroms_yaml.name): [results_type: 'vartrix_all_chroms_csv', auxiliary: true],
                (vartrix_outputs_barcodes.name): [results_type: 'vartrix_outputs_barcodes', auxiliary: false],
                (vartrix_outputs_variants.name): [results_type: 'vartrix_outputs_variants', auxiliary: false],
                (vartrix_outputs_ref_counts.name): [results_type: 'vartrix_outputs_ref_counts', auxiliary: false],
                (vartrix_outputs_alt_counts.name): [results_type: 'vartrix_outputs_alt_counts', auxiliary: false],
                (genotyper_csv.name): [results_type: 'genotyper_csv', auxiliary: false],
                (genotyper_yaml.name): [results_type: 'genotyper_csv', auxiliary: true],
            ]
        ]
        output_metadata['meta'] = metadata

        output_metadata_json = JsonOutput.toJson(output_metadata)

        """
        write_yaml_from_json.py '${output_metadata_json}' metadata.yaml
        """
}


workflow MONDRIAN_SNVGENOTYPING{

    take:
        bam_file
        vcf_files
        blacklist
        cell_barcodes
        reference_fasta
        metadata
        numlines
        numcores
        sample_id
    main:
        if ( cell_barcodes[0] ) {
            barcodes = RECOPY(cell_barcodes[1], 'barcodes.txt')
        } else {
            barcodes = GENERATEBARCODES(bam_file, bam_file+'.bai', 'barcodes.txt')
        }

        merged_vcf = MERGEVCFS(vcf_files.collect(), vcf_files.collect{it -> it+'.tbi'}, sample_id + '_merged_vcfs')
        uniq_calls = REMOVEDUPLICATES(merged_vcf[0], true, sample_id + '_unique_calls')

        if ( blacklist[0] ) {
            blacklist_calls = REMOVEBLACKLISTEDCALLS(uniq_calls[0], blacklist[1],sample_id + '_unique_blacklist_removed')
        } else {
            blacklist_calls = RECOPY(uniq_calls[0], sample_id + '_unique_blacklist_removed.vcf.gz')
        }
        chrom_vcfs = SPLITVCFBYNUMLINES(blacklist_calls[0], numlines)


        genotyper = PYSAMGENOTYPER(
            bam_file, bam_file+'.bai', chrom_vcfs.vcf.flatten(), barcodes,
            true, true, numcores, sample_id+'_pysam_genotyper'
        )

        vartrix = VARTRIX(
            bam_file, bam_file+'.bai', chrom_vcfs.vcf.flatten(), barcodes,
            reference_fasta, reference_fasta+'.fai', true,numcores,
            sample_id+'_vartrix'
        )
        vartrix_all_chroms = CONCATCSV(vartrix.csv.collect(), vartrix.yaml.collect(), sample_id+'_vartrix', false)

        vartrix_outputs = REGENERATEVARTRIXOUTPUTS(
            vartrix_all_chroms.csv,
            vartrix_all_chroms.yaml,
            sample_id+'_vartrix'
        )

        WRITEMETADATA(
            metadata,
            vartrix_all_chroms.csv,
            vartrix_all_chroms.yaml,
            vartrix_outputs.barcodes,
            vartrix_outputs.variants,
            vartrix_outputs.ref_counts,
            vartrix_outputs.alt_counts,
            genotyper.csv,
            genotyper.yaml,
        )
}