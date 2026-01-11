nextflow.enable.dsl=2

include { IDENTIFYNORMALS } from '../../modules/local/identify_normals'
include { SEPARATETUMORANDNORMALBAMS } from '../../modules/local/separate_tumor_and_normal_bams'


workflow MONDRIAN_NORMALIZER{

    take:
        reads
        metrics
        normal_copy
        bam
        qc_only
        aneuploidy_score_threshold
        ploidy_threshold
        sample_id

    main:

        normal_cells = IDENTIFYNORMALS(
            reads, reads+'.yaml', metrics, metrics+'.yaml', normal_copy,
            aneuploidy_score_threshold, ploidy_threshold, sample_id
        )

        if (! qc_only){
            separate_bams = SEPARATETUMORANDNORMALBAMS(
                bam, bam+'.bai',normal_cells.normal_yaml, sample_id
            )
        }
}
