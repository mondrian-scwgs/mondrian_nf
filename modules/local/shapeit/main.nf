process SHAPEIT {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    tuple(
      val(chromosome),
      path(bcf),
      path(bcf_idx),
      path(regions),
      path(regions_idx),
      path(genetic_map),
      val(phased_chromosomes),
      val(phased_chromosome_x),
      val(is_female),
      val(num_samples),
      val(confidence_threshold)
    )
  output:
    tuple(
      val(chromosome),
      path("haplotypes.csv.gz"),
      path("haplotypes.csv.gz.yaml")
    )

  script:
    def phased_chromosomes = '--phased_chromosomes ' + phased_chromosomes.join(' --phased_chromosomes ')
    def is_female = is_female ? " --is_female" : ''

    """

        haplotype_utils run-shapeit \
        --input_bcf_file ${bcf} \
        --genetic_map ${genetic_map} \
        --regions_file ${regions} \
        --chromosome ${chromosome} \
        --tempdir tempdir \
        --output haplotypes.tsv.gz \
        ${phased_chromosomes} \
        --phased_chromosome_x ${phased_chromosome_x} \
        --shapeit_num_samples ${num_samples} \
        --shapeit_confidence_threshold ${confidence_threshold} \
        ${is_female} \
        --output haplotypes.csv.gz

    """
}