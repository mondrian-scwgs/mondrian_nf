process MUTECT {
    time '48h'
    cpus 12
    memory '48 GB'
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

        gatk --java-options "-Xmx4G" GetSampleName -R ${reference} -I ${tumor_bam} -O tumor_name.txt
        gatk --java-options "-Xmx4G" GetSampleName -R ${reference} -I ${normal_bam} -O normal_name.txt
        mkdir raw_data

        if [[ ${numcores} -eq 1 ]]
        then
            gatk --java-options "-Xmx4G" Mutect2 \
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
            merge_vcf_inputs=""
            merge_stats_inputs=""
            for sub_interval in \${intervals}
                do
                    echo "gatk --java-options \\"-Xmx4G\\" Mutect2 \
                    -I ${normal_bam} -normal `cat normal_name.txt` \
                    -I ${tumor_bam}  -tumor `cat tumor_name.txt` \
                    -pon  ${panel_of_normals} \
                    --germline-resource  ${gnomad} \
                    --f1r2-tar-gz raw_data/\${sub_interval}_f1r2.tar.gz \
                    -R ${reference} -O raw_data/\${sub_interval}.vcf.gz  --intervals \${sub_interval} ">> commands.txt
                    merge_vcf_inputs="\${merge_vcf_inputs} --inputs raw_data/\${sub_interval}.vcf.gz"
                    merge_stats_inputs="\${merge_stats_inputs} -stats raw_data/\${sub_interval}.vcf.gz.stats"
                done
            parallel --jobs ${numcores} < commands.txt
            echo \${merge_vcf_inputs}
            echo \${merge_stats_inputs}
            variant_utils merge-vcf-files \${merge_vcf_inputs} --output merged.vcf
            gatk --java-options "-Xmx4G" MergeMutectStats \
                -stats \${merge_stats_inputs} -O merged.stats
        fi

        variant_utils fix-museq-vcf --input merged.vcf --output merged.fixed.vcf
        vcf-sort merged.fixed.vcf > ${filename}.vcf
        bgzip ${filename}.vcf -c > ${filename}.vcf.gz
        tabix -f -p vcf ${filename}.vcf.gz
    """

}
