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
    val(filename_prefix)
  output:
    path("${filename_prefix}_reference_cells.bam"), emit: bam
    path("${filename_prefix}_reference_cells.bam.bai"), emit: bai
    path("${filename_prefix}_contaminated_cells.bam"), emit: contaminated_bam
    path("${filename_prefix}_contaminated_cells.bam.bai"), emit: contaminated_bai
    path("${filename_prefix}_control_cells.bam"), emit: control_bam
    path("${filename_prefix}_control_cells.bam.bai"), emit: control_bai
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
              --contaminated_outfile ${filename_prefix}_contaminated_cells.bam \
              --control_outfile ${filename_prefix}_control_cells.bam \
              --pass_outfile ${filename_prefix}_reference_cells.bam \
              --reference ${reference}
    """

}
