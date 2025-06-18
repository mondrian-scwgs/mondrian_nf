process CREATESEGMENTS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(reference_fai)
    path(gap_table)
    val(chromosomes)
  output:
    path("segments.tsv"), emit: segments
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        haplotype_utils create-segments \
        --reference_fai ${reference_fai} \
        --gap_table ${gap_table} \
        ${chromosomes} \
        --output segments.tsv --tempdir temp
    """
}
