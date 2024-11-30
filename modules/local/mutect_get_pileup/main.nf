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
        merge_inputs=()
        for chromosome in ${chromosomes}; do
            gatk GetPileupSummaries \
                -R ${reference} -I ${bam} \
                --interval-set-rule INTERSECTION  -L \${chromosome} \
                -V ${variants_for_contamination} \
                -L ${variants_for_contamination} \
                -O ${filename}.\${chromosome}.table
            merge_inputs="\${merge_inputs} -I ${filename}.\${chromosome}.table"
        done
        gatk GatherPileupSummaries \
            --sequence-dictionary ${reference_dict} \
            \${merge_inputs} \
            -O ${filename}.tsv
    """
}
