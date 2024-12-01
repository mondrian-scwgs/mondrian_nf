import groovy.json.JsonOutput

nextflow.enable.dsl=2

include { DESTRUCT } from '../../modules/local/destruct'
include { EXTRACTSOMATIC } from '../../modules/local/destruct_extract_somatic'
include { EXTRACTCOUNTS } from '../../modules/local/destruct_extract_counts'
include { DESTRUCT_TO_VCF } from '../../modules/local/destruct_csv_to_vcf'


workflow MONDRIAN_DESTRUCT{

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

    main:
        destruct = DESTRUCT(
            normal, normal+'.bai', tumor, tumor+'.bai', reference, reference+'.fai', reference+'.1.ebwt', reference+'.2.ebwt',
            reference+'.3.ebwt', reference+'.4.ebwt', reference+'.rev.1.ebwt', reference+'.rev.2.ebwt', reference_dgv,
            reference_gtf, repeats, sample_id+'_destruct', numcores
        )
        extract_somatic = EXTRACTSOMATIC(destruct.table, destruct.library, sample_id+'_extract_somatic')
        destruct_vcf = DESTRUCT_TO_VCF(extract_somatic.breakpoints, reference, sample_id, sample_id+'_destruct')
        destruct_counts = EXTRACTCOUNTS(destruct.read, sample_id+'_counts')
}
