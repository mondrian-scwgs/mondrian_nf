process BAMMERGE{
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    val(cell_id)
    path(bamfile, stageAs: "?/*")
    path(baifile, stageAs: "?/*")
    path(reference)
    path(reference_fai)
    path(metrics)
    path(metrics_yaml)
  output:
    path("merged.bam"), emit: bam
    path("merged.bam.bai"), emit: bai
    path("contaminated.bam"), emit: contaminated_bam
    path("contaminated.bam.bai"), emit: contaminated_bai
    path("control.bam"), emit: control_bam
    path("control.bam.bai"), emit: control_bai
  script:
    def infiles = "--infiles " + bamfile.join(" --infiles ")
    def cell_ids = "--cell_ids " + cell_id.join(" --cell_ids ")
    """
        alignment_utils merge-cells \
              --metrics ${metrics} \
              ${infiles} \
              ${cell_ids} \
              --tempdir temp \
              --ncores ${task.cpus} \
              --contaminated_outfile contaminated.bam \
              --control_outfile control.bam \
              --pass_outfile merged.bam \
              --reference ${reference}
    """

}
