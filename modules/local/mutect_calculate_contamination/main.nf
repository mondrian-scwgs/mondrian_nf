process CALCULATECONTAMINATION {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(tumor_pileups)
    path(normal_pileups)
  output:
    path("contamination.table"), emit: table
    path("segments.table"), emit: segments
  script:
    """
        set -e
        gatk CalculateContamination \
        -I ${tumor_pileups}  -matched  ${normal_pileups} \
        -O contamination.table --tumor-segmentation segments.table
    """
}
