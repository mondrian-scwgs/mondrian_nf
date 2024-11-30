process GETPILEUP {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(reference)
    path(reference_fai)
    path(reference_dict)
    path(variants_for_contamination)
    path(variants_for_contamination_idx)
    val(chromosome)
    val(filename)
  output:
    path("${filename}.table"), emit: table
  script:
    def chromosomes = chromosome.join(' ')
    """
    true
    """
}
