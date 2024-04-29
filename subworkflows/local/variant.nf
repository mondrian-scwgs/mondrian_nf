nextflow.enable.dsl=2

include { GETREGIONS } from '../../modules/local/get_regions'
include { VARIANTBAM as NORMALVARIANTBAM } from '../../modules/local/variantbam'
include { VARIANTBAM as TUMORVARIANTBAM } from '../../modules/local/variantbam'
include { MERGEBAMS as NORMALMERGEBAMS } from '../../modules/local/merge_bams'
include { MERGEBAMS as TUMORMERGEBAMS } from '../../modules/local/merge_bams'
include { MUSEQ } from '../../modules/local/museq'
include { BCFTOOLSCONCATVCF as CONCAT_MUSEQ } from '../../modules/local/bcftools_concat_vcf'
include { REHEADERID as REHEADER_MUSEQ } from '../../modules/local/vcf_reheader_id'
include { GENERATECHROMDEPTH } from '../../modules/local/strelka_generate_chrom_depth'
include { GETGENOMESIZE } from '../../modules/local/strelka_get_genome_size'
include { STRELKA } from '../../modules/local/strelka'

include { BCFTOOLSCONCATVCF as CONCAT_STRELKA_SNV } from '../../modules/local/bcftools_concat_vcf'
include { FILTERVCF as FILTER_STRELKA_SNV } from '../../modules/local/bcftools_filter_vcf'
include { REHEADERID as REHEADER_STRELKA_SNV } from '../../modules/local/vcf_reheader_id'
include { BCFTOOLSCONCATVCF as CONCAT_STRELKA_INDEL } from '../../modules/local/bcftools_concat_vcf'
include { FILTERVCF as FILTER_STRELKA_INDEL } from '../../modules/local/bcftools_filter_vcf'
include { REHEADERID as REHEADER_STRELKA_INDEL } from '../../modules/local/vcf_reheader_id'

include { GETPILEUP as NORMAL_PILEUP } from '../../modules/local/mutect_get_pileup'
include { GETPILEUP as TUMOR_PILEUP } from '../../modules/local/mutect_get_pileup'
include { MERGEPILEUPS as NORMAL_MERGEPILEUPS } from '../../modules/local/mutect_merge_pileups'
include { MERGEPILEUPS as TUMOR_MERGEPILEUPS } from '../../modules/local/mutect_merge_pileups'

include { CALCULATECONTAMINATION } from '../../modules/local/mutect_calculate_contamination'
include { MUTECT } from '../../modules/local/mutect'
include { READORIENTATIONMODEL } from '../../modules/local/mutect_read_orientation_model'
include { MERGEVCFS } from '../../modules/local/mutect_merge_vcfs'
include { MERGESTATS } from '../../modules/local/mutect_merge_stats'
include { FILTERMUTECT } from '../../modules/local/mutect_filter_mutect'
include { FILTERALIGNMENTARTIFACTS } from '../../modules/local/mutect_filter_alignment_artifacts'

include { VARIANTCONSENSUS } from '../../modules/local/variant_consensus'

include { VCF2MAF } from '../../modules/local/vcf2maf'
include { REHEADERID as REHEADER_CONSENSUS } from '../../modules/local/vcf_reheader_id'

include { VARIANTMETADATA } from '../../modules/local/variant_metadata'


workflow MONDRIAN_VARIANT {

    take:
        normal
        tumor
        metadata
        chromosomes
        reference
        reference_dict
        panel_of_normals
        variants_for_contamination
        gnomad
        realignment_index_bundle
        vep_ref
        vep_fasta_suffix
        ncbi_build
        cache_version
        species
        sample_id
        numcores
        maxcoverage

    main:
        regions =  GETREGIONS(reference, chromosomes, 10000000)
        allregions = regions.map{it.readLines()}

        normals = NORMALVARIANTBAM(normal, normal+'.bai', allregions.flatten(), numcores, maxcoverage)
        normal_variant_bam=NORMALMERGEBAMS(normals.bam.collect(), 'merged_normal', numcores)
        tumors = TUMORVARIANTBAM(tumor, tumor+'.bai', allregions.flatten(), numcores, maxcoverage)
        tumor_variant_bam=TUMORMERGEBAMS(tumors.bam.collect(), 'merged_tumor', numcores)


        museq_vcfs = MUSEQ(
            normal_variant_bam.bam, normal_variant_bam.bai, tumor_variant_bam.bam, tumor_variant_bam.bai,
            reference, reference+'.fai', maxcoverage,allregions.flatten(),
            1, 'museq_vcf_interval'
        )
        museq_concat = CONCAT_MUSEQ(museq_vcfs.vcf.collect(), museq_vcfs.csi.collect())
        museq_reheader = REHEADER_MUSEQ(museq_concat.vcf, normal, tumor, 'TUMOUR', 'NORMAL', sample_id+'_museq')


        chrom_depth = GENERATECHROMDEPTH(normal_variant_bam.bam, normal_variant_bam.bai, reference, reference+'.fai', chromosomes)
        genome_size = GETGENOMESIZE(reference, reference+'.fai', chromosomes)
        strelka = STRELKA(
            normal_variant_bam.bam, normal_variant_bam.bai, tumor_variant_bam.bam, tumor_variant_bam.bai,
            reference, reference+'.fai', chrom_depth.txt, allregions.flatten(), genome_size.txt, numcores
        )

        concat_strelka_snv = CONCAT_STRELKA_SNV(strelka.snv_vcf.collect(), strelka.snv_csi.collect())
        filter_strelka_snv = FILTER_STRELKA_SNV(concat_strelka_snv.vcf, 'filter_strelka_snv')
        reheader_strelka_snv = REHEADER_STRELKA_SNV(filter_strelka_snv.vcf, normal, tumor, 'TUMOR', 'NORMAL', sample_id+'_strelka_snv')

        concat_strelka_indel = CONCAT_STRELKA_INDEL(strelka.indel_vcf.collect(), strelka.indel_csi.collect())
        filter_strelka_indel = FILTER_STRELKA_INDEL(concat_strelka_indel.vcf, 'filter_strelka_indel')
        reheader_strelka_indel = REHEADER_STRELKA_INDEL(filter_strelka_indel.vcf, normal, tumor, 'TUMOR', 'NORMAL', sample_id+'_strelka_indel')


        if (variants_for_contamination[0]) {
            normal_pileups=NORMAL_PILEUP(
                normal_variant_bam.bam, reference, reference+'.fai', reference_dict,
                variants_for_contamination, variants_for_contamination+'.tbi', chromosomes.flatten(), 'normal'
            )
            tumor_pileups=TUMOR_PILEUP(
                tumor_variant_bam.bam, reference, reference+'.fai', reference_dict,
                variants_for_contamination, variants_for_contamination+'.tbi', chromosomes.flatten(), 'tumor'
            )
            normal_merged_pileups = NORMAL_MERGEPILEUPS(normal_pileups.table, reference_dict, 'normal_pileups_merged')
            tumor_merged_pileups = TUMOR_MERGEPILEUPS(tumor_pileups.table, reference_dict, 'tumor_pileups_merged')
            contamination = CALCULATECONTAMINATION(tumor_merged_pileups.tsv, normal_merged_pileups.tsv)
            contamination_table = contamination.table
            contamination_segments = contamination.segments
            has_contamination_data = true
        } else {
            contamination_table = file("$baseDir/assets/dummy_file.txt")
            contamination_segments = file("$baseDir/assets/dummy_file.txt")
            has_contamination_data = false
        }


        mutect = MUTECT(
            normal_variant_bam.bam, normal_variant_bam.bai, tumor_variant_bam.bam, tumor_variant_bam.bai,
            reference, reference+'.fai', reference_dict, panel_of_normals, panel_of_normals+'.tbi',
            gnomad, gnomad+'.tbi', allregions.flatten(), numcores, sample_id+'_mutect'
        )

        orientation_model = READORIENTATIONMODEL(mutect.f1r2.collect())
        merge_vcfs = MERGEVCFS(mutect.vcf.collect(), mutect.tbi.collect(), sample_id+'_merged_mutect')
        merge_stats = MERGESTATS(mutect.stats.collect(), sample_id+'_merged_stats')

        filter_mutect = FILTERMUTECT(
            reference, reference+'.fai', reference_dict, merge_vcfs.vcf, merge_vcfs.tbi,
            merge_stats.stats, has_contamination_data, contamination_table, contamination_segments, orientation_model.artifact_priors,
            sample_id+'_filter_mutect'
        )


        if (realignment_index_bundle[0]){
            alignment_artifacts = FILTERALIGNMENTARTIFACTS(
                reference, reference+'.fai', reference_dict, realignment_index_bundle[1],
                filter_mutect.vcf, filter_mutect.tbi,  tumor_variant_bam.bam, tumor_variant_bam.bai,
                sample_id+'_mutect'
            )
            mutect_vcf = alignment_artifacts.vcf
            mutect_tbi = alignment_artifacts.tbi
        } else {
            mutect_vcf = filter_mutect.vcf
            mutect_tbi = filter_mutect.tbi
        }

        consensus = VARIANTCONSENSUS(
            museq_reheader.vcf, museq_reheader.tbi, reheader_strelka_snv.vcf, reheader_strelka_snv.tbi,
            reheader_strelka_indel.vcf, reheader_strelka_indel.tbi, mutect_vcf, mutect_tbi,
            chromosomes, sample_id+'_consensus'
        )

        vcf2maf = VCF2MAF(consensus.vcf, vep_ref, vep_fasta_suffix, ncbi_build, cache_version, species, sample_id+'_consensus')

        VARIANTMETADATA(
            vcf2maf.maf, consensus.vcf, consensus.tbi, museq_reheader.vcf, museq_reheader.tbi,
            mutect_vcf, mutect_tbi, reheader_strelka_snv.vcf, reheader_strelka_snv.tbi,
            reheader_strelka_indel.vcf, reheader_strelka_indel.tbi, metadata
        )

}
