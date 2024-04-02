process STRELKA {
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
    path(chrom_depth)
    val(interval)
    path(genome_size)
    val(numcores)
  output:
    path("merged_indels.sorted.fixed.vcf.gz"), emit: indel_vcf
    path("merged_indels.sorted.fixed.vcf.gz.csi"), emit: indel_csi
    path("merged_indels.sorted.fixed.vcf.gz.tbi"), emit: indel_tbi
    path("merged_snv.sorted.fixed.vcf.gz"), emit: snv_vcf
    path("merged_snv.sorted.fixed.vcf.gz.csi"), emit: snv_csi
    path("merged_snv.sorted.fixed.vcf.gz.tbi"), emit: snv_tbi
    path("*stats.txt"), emit: stats
  script:
    """
        genome_size=`cat ${genome_size}`
        max_indel_size=50
        min_qscore=0
        max_window_mismatch="3 20"
        indel_nonsite_match_prob=0.5
        tier2_mismatch_density_filter_count=10
        tier2_indel_nonsite_match_prob=0.25
        depth_filter_multiple=3.0
        snv_max_filtered_basecall_frac=0.4
        snv_max_spanning_deletion_frac=0.75
        indel_max_window_filtered_basecall_frac=0.3
        ssnv_prior=0.0001
        sindel_prior=0.000001
        ssnv_noise=0.0000000005
        sindel_noise_factor=2.2
        ssnv_noise_strand_bias_frac=0.0
        min_tier1_mapq=20
        min_tier2_mapq=0
        ssnv_quality_lower_bound=15
        sindel_quality_lower_bound=40
        ssnv_contam_tolerance=0.15
        indel_contam_tolerance=0.15


        if [[ ${numcores} -eq 1 ]]
        then
            run_strelka ${normal_bam} ${tumor_bam} merged_indels.vcf merged_snv.vcf ${interval}.stats.txt ${interval} ${reference} \${genome_size} \
            -max-indel-size 50 -min-qscore \${min_qscore} -max-window-mismatch \${max_window_mismatch} \
            -indel-nonsite-match-prob \${indel_nonsite_match_prob} \
            --tier2-mismatch-density-filter-count \${tier2_mismatch_density_filter_count} \
            --tier2-indel-nonsite-match-prob \${tier2_indel_nonsite_match_prob} \
            -min-mapping-quality \${min_tier1_mapq} \
            --somatic-snv-rate \${ssnv_prior} \
            --shared-site-error-rate \${ssnv_noise} \
            --shared-site-error-strand-bias-fraction \${ssnv_noise_strand_bias_frac} \
            --somatic-indel-rate \${sindel_prior} \
            --shared-indel-error-factor \${sindel_noise_factor} \
            --tier2-min-mapping-quality \${min_tier2_mapq} \
            --tier2-include-singleton \
            --tier2-include-anomalous \
            --strelka-snv-max-filtered-basecall-frac \${snv_max_filtered_basecall_frac} \
            --strelka-snv-max-spanning-deletion-frac \${snv_max_spanning_deletion_frac} \
            --strelka-snv-min-qss-ref \${ssnv_quality_lower_bound} \
            --strelka-indel-max-window-filtered-basecall-frac \${indel_max_window_filtered_basecall_frac} \
            --strelka-indel-min-qsi-ref \${sindel_quality_lower_bound} \
            --ssnv-contam-tolerance \${ssnv_contam_tolerance} \
            --indel-contam-tolerance \${indel_contam_tolerance} \
            --strelka-chrom-depth-file ${chrom_depth} \
            --strelka-max-depth-factor \${depth_filter_multiple}
        else
            intervals=`variant_utils split-interval --interval ${interval} --num_splits ${numcores}`
            for interval in \$intervals
                do
                    echo "run_strelka ${normal_bam} ${tumor_bam} \${interval}.indels.vcf \${interval}.snv.vcf \${interval}.stats.txt \${interval} \
                    ${reference} \${genome_size} \
                    -max-indel-size 50 -min-qscore \${min_qscore} -max-window-mismatch \${max_window_mismatch} \
                    -indel-nonsite-match-prob \${indel_nonsite_match_prob} \
                    --tier2-mismatch-density-filter-count \${tier2_mismatch_density_filter_count} \
                    --tier2-indel-nonsite-match-prob \${tier2_indel_nonsite_match_prob} \
                    -min-mapping-quality \${min_tier1_mapq} \
                    --somatic-snv-rate \${ssnv_prior} \
                    --shared-site-error-rate \${ssnv_noise} \
                    --shared-site-error-strand-bias-fraction \${ssnv_noise_strand_bias_frac} \
                    --somatic-indel-rate \${sindel_prior} \
                    --shared-indel-error-factor \${sindel_noise_factor} \
                    --tier2-min-mapping-quality \${min_tier2_mapq} \
                    --tier2-include-singleton \
                    --tier2-include-anomalous \
                    --strelka-snv-max-filtered-basecall-frac \${snv_max_filtered_basecall_frac} \
                    --strelka-snv-max-spanning-deletion-frac \${snv_max_spanning_deletion_frac} \
                    --strelka-snv-min-qss-ref \${ssnv_quality_lower_bound} \
                    --strelka-indel-max-window-filtered-basecall-frac \${indel_max_window_filtered_basecall_frac} \
                    --strelka-indel-min-qsi-ref \${sindel_quality_lower_bound} \
                    --ssnv-contam-tolerance \${ssnv_contam_tolerance} \
                    --indel-contam-tolerance \${indel_contam_tolerance} \
                    --strelka-chrom-depth-file ${chrom_depth} \
                    --strelka-max-depth-factor \${depth_filter_multiple}" >> commands.txt
                done
            parallel --jobs ${numcores} < commands.txt
            variant_utils merge-vcf-files --inputs *.snv.vcf --output merged_snv.vcf
            variant_utils merge-vcf-files --inputs *.indels.vcf --output merged_indels.vcf
        fi

        variant_utils fix-museq-vcf --input merged_snv.vcf --output merged_snv.fixed.vcf
        vcf-sort merged_snv.fixed.vcf > merged_snv.sorted.fixed.vcf
        bgzip merged_snv.sorted.fixed.vcf -c > merged_snv.sorted.fixed.vcf.gz
        bcftools index merged_snv.sorted.fixed.vcf.gz
        tabix -f -p vcf merged_snv.sorted.fixed.vcf.gz

        variant_utils fix-museq-vcf --input merged_indels.vcf --output merged_indels.fixed.vcf
        vcf-sort merged_indels.fixed.vcf > merged_indels.sorted.fixed.vcf
        bgzip merged_indels.sorted.fixed.vcf -c > merged_indels.sorted.fixed.vcf.gz
        bcftools index merged_indels.sorted.fixed.vcf.gz
        tabix -f -p vcf merged_indels.sorted.fixed.vcf.gz


    """

}
