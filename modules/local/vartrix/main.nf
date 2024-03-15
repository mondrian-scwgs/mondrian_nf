process VARTRIX {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(bai)
    path(vcf_file)
    path(cell_barcodes)
    path(reference_fasta)
    path(reference_fai)
    val(skip_header)
    val(num_threads)
    val(filename)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml
  script:
    def skip_header_arg = skip_header ? "--skip_header" : ""
    """
        vartrix_linux --bam ${bam} \
        --fasta ${reference_fasta} --vcf ${vcf_file} \
         --cell-barcodes ${cell_barcodes} \
        --scoring-method coverage \
        --out-barcodes out_snv_barcodes.txt \
        --out-matrix out_snv_alt.mtx \
        --out-variants out_snv_variants.txt \
        --ref-matrix out_snv_ref.mtx \
        --mapq 20 \
        --no-duplicates \
        --primary-alignments \
        --threads ${num_threads}

        snv_genotyping_utils parse-vartrix \
        --barcode out_snv_barcodes.txt \
        --variant out_snv_variants.txt \
        --ref_matrix out_snv_ref.mtx \
        --alt_matrix out_snv_alt.mtx \
        --vcf_file ${vcf_file} \
        --parsed_output ${filename}.csv.gz \
        --tempdir tempdir \
        ${skip_header_arg}
    """
}
