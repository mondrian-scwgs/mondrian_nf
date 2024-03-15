nextflow.enable.dsl=2

include { GETREGIONS } from '../../modules/local/get_regions'
include { BCFTOOLSMPILEUP } from '../../modules/local/bcftools_mpileup'
include { BCFTOOLSFILTERHET } from '../../modules/local/bcftools_filter_het'
include { BCFTOOLSCONCATVCF } from '../../modules/local/bcftools_concat_vcf'
include { CONCATCSV } from '../../modules/local/csverve_concat_csv'
include { SHAPEIT } from '../../modules/local/shapeit'
include { INFERHAPSMETADATA } from '../../modules/local/infer_haps_metadata'


workflow MONDRIAN_INFERHAPS{

    take:
        bam
        reference_fasta
        chromosome_references
        phased_chromosomes
        phased_chromosome_x
        metadata_input
        is_female
        sample_id

    main:

        references = Channel.fromPath(chromosome_references).splitCsv(header:true, sep:',')

        references = references.map{it -> tuple(it.chromosome, it.regions_vcf, it.genetic_map)}

        chromosomes = references.map{it->it[0]}

        regions =  GETREGIONS(reference_fasta, chromosomes, 10000000)

        allregions = regions
                       .map{it -> tuple(it[0], it[1].readLines())}
                       .transpose()
                       .combine(references, by:0)


        mpileup_tup = allregions
                        .map{it -> tuple(
                            it[0], bam, bam+'.bai', reference_fasta, reference_fasta+'.fai',
                            it[2],it[2]+'.csi', it[1])
                            }
        mpileup_vcfs = BCFTOOLSMPILEUP(mpileup_tup)


        filtered_vcfs = BCFTOOLSFILTERHET(mpileup_vcfs)

        x = filtered_vcfs.map{it -> tuple(it[0], it[1])}.groupTuple()
        y = filtered_vcfs.map{it -> tuple(it[0], it[2])}.groupTuple()
        grouped_by_chrom = x.combine(y, by: 0)
        vcfs = BCFTOOLSCONCATVCF(grouped_by_chrom)

        shapeit_input = vcfs
                          .combine(references, by: 0)
                          .map{it -> tuple(
                            it[0], it[1], it[2], it[3], it[3]+'.csi', it[4],
                            phased_chromosomes, phased_chromosome_x, is_female,
                            100, 0.95)
                          }
        shapeit_files= SHAPEIT(shapeit_input)

        outputs = CONCATCSV(shapeit_files.collect{it[1]}, shapeit_files.collect{it[2]}, 'inferhaps', false)

        INFERHAPSMETADATA(
            output.csv, output.yaml, metadata_input
        )
}