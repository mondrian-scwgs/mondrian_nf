process PYSAMGENOTYPER {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bam)
    path(bai)
    path(vcf_file)
    path(cell_barcodes)
    val(ignore_untagged_reads)
    val(skip_header)
    val(num_threads)
    val(filename)
  output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml
  script:
    def sparse_arg = "--sparse"
    def skip_header_arg = skip_header ? "--skip_header" : ""
    def ignore_untagged_reads_arg = ignore_untagged_reads ? "--ignore_untagged_reads" : ""
    def cell_barcodes_arg = cell_barcodes ? "--cell_barcodes "+cell_barcodes : ""
    """

        if [[ ${num_threads} -eq 1 ]]
        then
            snv_genotyping_utils snv-genotyper --bam ${bam}  ${cell_barcodes_arg} \
            --targets_vcf ${vcf_file} --output ${filename}.csv.gz \
            ${ignore_untagged_reads_arg} ${skip_header_arg} ${sparse_arg}
        else
            mkdir tempdir
            mkdir outdir
            io_utils split-vcf --infile ${vcf_file} --outdir tempdir/vcf_split --num_lines 5000
            gunzip tempdir/vcf_split/*
            ls tempdir/vcf_split|while read x; do bgzip tempdir/vcf_split/${x} && tabix tempdir/vcf_split/${x} ;done
            split_vcf_files=`ls tempdir/vcf_split/*.vcf.gz`

            for split_vcf_file in \${split_vcf_files}
                do
                    echo "snv_genotyping_utils snv-genotyper \
                    --bam ${bam}  ${cell_barcodes_arg} ${ignore_untagged_reads_arg} ${skip_header_arg} ${sparse_arg}\
                     --targets_vcf \${split_vcf_file}  --output \${split_vcf_file}.genotype.csv.gz" >> commands.txt
                done
            parallel --jobs ${num_threads} < commands.txt

            inputs=`echo tempdir/vcf_split/*.genotype.csv.gz | sed "s/ / --in_f /g"`
            csverve concat --in_f \$inputs  --out_f ${filename}.csv.gz
        fi
    """
}
