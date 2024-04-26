process PYSAMGENOTYPER {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(bai)
    path(vcf_file)
    path(vcf_file_idx)
    path(cell_barcodes)
    val(interval)
    val(ignore_untagged_reads)
    val(skip_header)
    val(num_threads)
    val(filename)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml
  script:
    def skip_header_arg = skip_header ? "--skip_header" : ""
    def skip_header_arg = ignore_untagged_reads ? "--ignore_untagged_reads" : ""
    def cell_barcodes_arg = cell_barcodes ? "--cell_barcodes "+cell_barcodes : ""

    """

        if [[ ${num_threads} -eq 1 ]]
        then
            snv_genotyping_utils snv-genotyper --bam ${bam}  ${cell_barcodes} \
            --targets_vcf ${vcf_file} --output ${filename_prefix}.csv.gz \
            ~{true='--ignore_untagged_reads' false='' ignore_untagged_reads} \
            ~{'--interval' + interval} \
            ~{true='--skip_header' false='' skip_header} \
            ~{true='--sparse' false='' sparse}
        else
            mkdir outdir
            intervals=`variant_utils split-interval --interval ~{interval} --num_splits ~{num_threads}`
            for interval in ${intervals}
                do
                    echo "snv_genotyping_utils snv-genotyper \
                    ~{'--interval' + interval}  --bam ~{bam}  ~{"--cell_barcodes "+cell_barcodes} \
                    ~{true='--ignore_untagged_reads' false='' ignore_untagged_reads} \
                    ~{true='--skip_header' false='' skip_header} \
                    ~{true='--sparse' false='' sparse} \
                     --targets_vcf ~{vcf_file}  --output outdir/${interval}.genotype.csv.gz" >> commands.txt
                done
            parallel --jobs ~{num_threads} < commands.txt

            inputs=`echo outdir/*genotype.csv.gz | sed "s/ / --in_f /g"`
            csverve concat --in_f $inputs  --out_f ~{filename_prefix}.csv.gz
        fi




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
