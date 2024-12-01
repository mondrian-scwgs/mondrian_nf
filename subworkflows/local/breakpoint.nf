nextflow.enable.dsl=2

include { GETDISCORDANT as GETNORMALDISCORDANT } from '../../modules/local/samtools_get_discordant'
include { GETDISCORDANT as GETTUMORDISCORDANT } from '../../modules/local/samtools_get_discordant'
include { GETSPLIT as GETNORMALSPLIT } from '../../modules/local/lumpy_get_split'
include { GETSPLIT as GETTUMORSPLIT } from '../../modules/local/lumpy_get_split'
include { LUMPYEXPRESS } from '../../modules/local/lumpyexpress'
include { GRIDSS } from '../../modules/local/gridss'
include { SVABA } from '../../modules/local/svaba'
include { DESTRUCT } from '../../modules/local/destruct'
include { EXTRACTSOMATIC } from '../../modules/local/destruct_extract_somatic'
include { EXTRACTCOUNTS } from '../../modules/local/destruct_extract_counts'
include { DESTRUCT_TO_VCF } from '../../modules/local/destruct_csv_to_vcf'
include { GETREGIONS } from '../../modules/local/get_regions'
include { BREAKPOINTCONSENSUS } from '../../modules/local/breakpoint_consensus'
include { CONCATCSV } from '../../modules/local/csverve_concat_csv'
include { CSVERVEREMOVEDUPLICATES } from '../../modules/local/csverve_remove_duplicates'


workflow MONDRIAN_BREAKPOINT{

    take:
        normal
        tumor
        chromosomes
        reference
        reference_gtf
        reference_dgv
        repeats
        blacklist
        sample_id
        numcores
        jvm_heap_gb

    main:
        normal_discordant = GETNORMALDISCORDANT(normal)
        tumor_discordant = GETTUMORDISCORDANT(tumor)
        normal_split = GETNORMALSPLIT(normal)
        tumor_split = GETTUMORSPLIT(tumor)
        lumpy = LUMPYEXPRESS(
            normal, tumor, normal_discordant.bam, tumor_discordant.bam,
            normal_split.bam, tumor_split.bam, sample_id+'_lumpy'
        )

        gridss = GRIDSS(
            normal, tumor, reference, reference+'.fai', reference+'.amb', reference+'.ann', reference+'.bwt',
            reference+'.pac',reference+'.sa', sample_id+'_gridss', numcores, jvm_heap_gb
        )

        svaba = SVABA(
            normal, normal+'.bai', tumor, tumor+'.bai', reference, reference+'.fai', reference+'.amb', reference+'.ann', reference+'.bwt',
            reference+'.pac',reference+'.sa', sample_id+'_svaba', numcores
        )

        destruct = DESTRUCT(
            normal, normal+'.bai', tumor, tumor+'.bai', reference, reference+'.fai', reference+'.1.ebwt', reference+'.2.ebwt',
            reference+'.3.ebwt', reference+'.4.ebwt', reference+'.rev.1.ebwt', reference+'.rev.2.ebwt', reference_dgv,
            reference_gtf, repeats, sample_id+'_destruct', numcores
        )
        extract_somatic = EXTRACTSOMATIC(destruct.table, destruct.library, sample_id+'_extract_somatic')
        destruct_vcf = DESTRUCT_TO_VCF(extract_somatic.breakpoints, reference, sample_id, sample_id+'_destruct')
        destruct_counts = EXTRACTCOUNTS(destruct.read, sample_id+'_counts')


        regions =  GETREGIONS(reference, chromosomes, 10000000)
        allregions = regions.map{it.readLines()}

        breakpoint_consensus = BREAKPOINTCONSENSUS(
            extract_somatic.breakpoints, lumpy.vcf, gridss.vcf, svaba.vcf, blacklist[1], blacklist[0],
            sample_id, sample_id+'_consensus', allregions.flatten()
        )
        allele_counts_concat = CONCATCSV(
            breakpoint_consensus.csv.collect(), breakpoint_consensus.yaml.collect(), sample_id+'_merged_consensus', true
        )
        allele_counts = CSVERVEREMOVEDUPLICATES(allele_counts_concat.csv, allele_counts_concat.yaml, sample_id+'_consensus')
}