process BCFTOOLSMPILEUP {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

    input:
      tuple(
        val(chromosome),
        path(bam),
        path(bai),
        path(reference_fasta),
        path(reference_fasta_fai),
        path(regions_vcf),
        path(regions_vcf_idx),
        val(region)
      )
    output:
      tuple(
        val(chromosome),
        path("chromosome_calls_reheader.vcf.gz"),
        path("chromosome_calls_reheader.vcf.gz.csi")
      )

    script:
      """
        bcftools view -Oz ${regions_vcf} ${region} > subset.vcf.gz

        numcalls=`zcat subset.vcf.gz  | grep -v "#" | wc -l`

        if [ \$numcalls == 0 ]; then
            gunzip < subset.vcf.gz | head -n -1 > subset.vcf
            echo -e "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t~{bam}" >> subset.vcf
            bgzip subset.vcf -f
            cp subset.vcf.gz chromosome_mpileup.vcf.gz
        else
            bcftools \
            mpileup -Oz \
            -f ${reference_fasta} \
            --regions-file subset.vcf.gz \
            ${bam} \
             -o chromosome_mpileup.vcf.gz
        fi

        bcftools call -Oz \
        -c chromosome_mpileup.vcf.gz \
        -o chromosome_calls.vcf.gz

        echo \$(basename ${bam}) >> samples
        bcftools reheader --samples samples chromosome_calls.vcf.gz > chromosome_calls_reheader.vcf.gz
        bcftools index chromosome_calls_reheader.vcf.gz

      """
}