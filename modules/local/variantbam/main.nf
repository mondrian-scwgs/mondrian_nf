process VARIANTBAM {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'


    input:
        path(bam)
        path(bai)
        val(interval)
        val(numcores)
        val(max_coverage)

    output:
        path("output.bam"), emit: bam
        path("output.bam.bai"), emit: bai

    script:
    """
        if [[ ${numcores} -eq 1 ]]
        then
            variant ${bam} -m ${max_coverage} -k ${interval} -v -b -o output.bam
        else
            mkdir variant_bam
            split_intervals=`variant_utils split-interval --interval ${interval} --num_splits ${numcores}`
            for splitinterval in \${split_intervals}
                do
                    echo "variant ${bam} -m ${max_coverage} -k \${splitinterval} -v -b -o variant_bam/\${splitinterval}.bam" >> variant_commands.txt
                done
            parallel --jobs ${numcores} < variant_commands.txt
            sambamba merge -t ${numcores} output.bam variant_bam/*bam
        fi
        samtools index output.bam
    """

}