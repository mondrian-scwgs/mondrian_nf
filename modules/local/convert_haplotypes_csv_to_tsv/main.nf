process CONVERTHAPLOTYPESCSVTOTSV {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(infile)
    path(infile_yaml)
  output:
    path("haplotypes.tsv"), emit: haplotypes
  script:
    """
        haplotype_utils convert-haplotypes-csv-to-tsv \
        --input ${infile} \
        --output haplotypes.tsv
    """
}
