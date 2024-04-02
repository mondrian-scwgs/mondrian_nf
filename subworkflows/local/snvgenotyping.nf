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
include { SNVGENOTYPINGMETADATA } from '../../modules/local/snv_genotyping_metadata'


workflow MONDRIAN_SNVGENOTYPING{

    take:
        bam_file
        vcf_files
        blacklist
        cell_barcodes
        reference_fasta
        metadata_input
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

        SNVGENOTYPINGMETADATA(
            vartrix_all_chroms.csv, vartrix_all_chroms.yaml, vartrix_outputs.barcodes, vartrix_outputs.variants,
            vartrix_outputs.ref_counts, vartrix_outputs.alt_counts, metadata_input

        )

}