process SPLITBYCHROM {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(vcf_file)
  output:
    path("temp_output/*.vcf.gz"), emit: vcf
    path("temp_output/*.vcf.gz.tbi"), emit: tbi
  script:
    """
        io_utils split-vcf-by-chrom --infile ${vcf_file} --outdir temp_output
        ls temp_output|while read x; do bgzip temp_output/\${x} && tabix temp_output/\${x}.gz;done
    """
}
