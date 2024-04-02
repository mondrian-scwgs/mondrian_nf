nextflow.enable.dsl=2


include { SPLITBAM } from '../../modules/local/split_bam'
include { CREATESEGMENTS } from '../../modules/local/create_segments'
include { CONVERTHAPLOTYPESCSVTOTSV } from '../../modules/local/convert_haplotypes_csv_to_tsv'
include { EXTRACTSEQDATAANDREADCOUNT } from '../../modules/local/extract_seqdata_and_readcount'
include { CONCATCSV as CONCATALLELECOUNTS } from '../../modules/local/csverve_concat_csv'
include { COUNTHAPSMETADATA } from '../../modules/local/count_haps_metadata'


workflow MONDRIAN_COUNTHAPS{

    take:
        tumor_bam
        haplotypes_csv
        snp_positions
        reference_fasta
        metadata_input
        gap_table
        chromosomes
        numcores
        sample_id
    main:

        splitbams = SPLITBAM(
            tumor_bam, tumor_bam+'.bai', chromosomes, numcores
        )

        segments = CREATESEGMENTS(
            reference_fasta+'.fai', gap_table, chromosomes
        )

        haps = CONVERTHAPLOTYPESCSVTOTSV(
           haplotypes_csv, haplotypes_csv+'.yaml'
        )

        cell_allele_counts = EXTRACTSEQDATAANDREADCOUNT(
            splitbams.flatten(),
            snp_positions,
            segments,
            haps,
            chromosomes
        )

        allele_counts = CONCATALLELECOUNTS(
            cell_allele_counts.csv.collect(), cell_allele_counts.yaml.collect(), sample_id+'_allele_count', true
        )

        COUNTHAPSMETADATA(
        allele_counts.csv, allele_counts.yaml, metadata_input
        )

}