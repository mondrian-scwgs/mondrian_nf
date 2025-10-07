process SPLITVCFBYNUMLINES {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_file)
    val(num_lines)
  output:
    path("temp_output/*.vcf.gz"), emit: vcf
    path("temp_output/*.vcf.gz.tbi"), emit: tbi
  script:
    """
        io_utils split-vcf --infile ${vcf_file} --outdir temp_output --num_lines ${num_lines}
        ls temp_output|while read x; do bgzip temp_output/\${x} && tabix temp_output/\${x}.gz;done
    """
}
