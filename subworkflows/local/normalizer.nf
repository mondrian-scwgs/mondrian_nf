nextflow.enable.dsl=2

include { IDENTIFYNORMALS } from '../../modules/local/identify_normals'
include { ANEUPLOIDYHEATMAP } from '../../modules/local/aneuploidy_heatmap'
include { SEPARATETUMORANDNORMALBAMS } from '../../modules/local/separate_tumor_and_normal_bams'


workflow MONDRIAN_NORMALIZER{

    take:
        reads
        metrics
        bam
        blacklist
        qc_only
        chromosomes
        relative_aneuploidy_threshold
        ploidy_threshold
        allowed_aneuploidy_score
        sample_id

    main:

        normal_cells = IDENTIFYNORMALS(
            reads, reads+'.yaml', metrics, metrics+'.yaml', blacklist[1], blacklist[0],
            relative_aneuploidy_threshold, ploidy_threshold, allowed_aneuploidy_score,
            sample_id
        )

        heatmap = ANEUPLOIDYHEATMAP(
            normal_cells.csv, normal_cells.yaml, reads, reads+'.yaml', allowed_aneuploidy_score, sample_id
        )

        if (! qc_only){
            separate_bams = SEPARATETUMORANDNORMALBAMS(
                bam, bam+'.bai',normal_cells.normal_yaml, sample_id
            )
        }
}
