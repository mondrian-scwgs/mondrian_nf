process GENERATECHROMDEPTH {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(bai)
    path(reference)
    path(reference_fai)
    val(chromosomes)
  output:
    path("chrom_depth.txt"), emit: txt
  script:
    def chromosomes = chromosomes.join(" ")
    """
        mkdir raw_data
        merge_inputs=""
        for interval in ${chromosomes}
            do
                GetChromDepth --align-file ${bam} --chrom \${interval} --output-file raw_data/\${interval}.chrom_depth.txt
                merge_inputs="\${merge_inputs} --inputs raw_data/\${interval}.chrom_depth.txt"
            done
        variant_utils merge-chromosome-depths-strelka \${merge_inputs} --output chrom_depth.txt
    """

}
