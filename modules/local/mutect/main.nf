process MUTECT {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(normal_bai)
    path(tumor_bam)
    path(tumor_bai)
    path(reference)
    path(reference_fai)
    path(reference_dict)
    path(panel_of_normals)
    path(panel_of_normals_idx)
    path(gnomad)
    path(gnomad_idx)
    val(interval)
    val(numcores)
    val(filename)
  output:
    path("${filename}.vcf.gz"), emit: vcf
    path("${filename}.vcf.gz.tbi"), emit: tbi
    path("${filename}.stats"), emit: stats
    path("raw_data/*_f1r2.tar.gz"), emit: f1r2
  script:
    """
        set -e

        gatk GetSampleName -R ${reference} -I ${tumor_bam} -O tumor_name.txt
        gatk GetSampleName -R ${reference} -I ${normal_bam} -O normal_name.txt
        mkdir raw_data

        if [[ ${numcores} -eq 1 ]]
        then
            gatk Mutect2 \
            -I ${normal_bam} -normal `cat normal_name.txt` \
            -I ${tumor_bam}  -tumor `cat tumor_name.txt` \
            -pon ${panel_of_normals} \
            --germline-resource  ${gnomad} \
            --f1r2-tar-gz raw_data/${interval}_f1r2.tar.gz \
            -R ${reference} -O raw_data/${interval}.vcf  --intervals ${interval}
            mv raw_data/${interval}.vcf merged.vcf
            mv raw_data/${interval}.vcf.stats ${filename}.stats
        else
            intervals=`variant_utils split-interval --interval ${interval} --num_splits ${numcores}`
            echo \${intervals}
            for interval in \${intervals}
                do
                    echo "gatk Mutect2 \
                    -I ${normal_bam} -normal `cat normal_name.txt` \
                    -I ${tumor_bam}  -tumor `cat tumor_name.txt` \
                    -pon  ${panel_of_normals} \
                    --germline-resource  ${gnomad} \
                    --f1r2-tar-gz raw_data/${interval}_f1r2.tar.gz \
                    -R ${reference} -O raw_data/${interval}.vcf.gz  --intervals ${interval} ">> commands.txt
                done
            parallel --jobs ${numcores} < commands.txt
            variant_utils merge-vcf-files --inputs raw_data/*vcf.gz --output merged.vcf
            inputs=`ls raw_data/*stats | awk 'ORS=" -stats "' | head -c -8`
            echo \${inputs}
            gatk --java-options "-Xmx4G" MergeMutectStats \
                -stats \${inputs} -O merged.stats
        fi

        variant_utils fix-museq-vcf --input merged.vcf --output merged.fixed.vcf
        vcf-sort merged.fixed.vcf > ${filename}.vcf
        bgzip ${filename}.vcf -c > ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
    """

}
