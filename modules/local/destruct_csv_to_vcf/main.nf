process DESTRUCT_TO_VCF {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

    input:
    path(destruct_csv)
    path(reference_fasta)
    val(sample_id)
    val(filename)

    output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi

    script:
    """
        breakpoint_utils breakpoint-destruct-csv-to-vcf \
        --infile ${destruct_csv} \
        --reference ${reference_fasta} \
        --outfile destruct.vcf \
        --sample_id ${sample_id}

        vcf-sort destruct.vcf > destruct.sorted.vcf
        bgzip destruct.sorted.vcf -c > ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
    """
}