process REGENERATEVARTRIXOUTPUTS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(csv)
    path(yaml)
    val(filename)
  output:
    path("${filename}_barcodes.txt"), emit: barcodes
    path("${filename}_variants.txt"), emit: variants
    path("${filename}_ref_counts.mtx"), emit: ref_counts
    path("${filename}_alt_counts.mtx"), emit: alt_counts
  script:
    """
        snv_genotyping_utils regenerate-vartrix-format \
        --barcodes ${filename}_barcodes.txt \
        --variants ${filename}_variants.txt \
        --ref_matrix ${filename}_ref_counts.mtx \
        --alt_matrix ${filename}_alt_counts.mtx \
        --parsed_data ${csv} \
        --tempdir tempdir
    """

}
