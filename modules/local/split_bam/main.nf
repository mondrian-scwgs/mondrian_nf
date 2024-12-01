process SPLITBAM {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(bamfile)
    path(baifile)
    val(num_threads)
  output:
    path("outdir/*bam"), emit: bams
  script:
    """
        ulimit -n 5250

        mkdir outdir
        samtools split -d CB -M 5200 --output-fmt bam -f 'outdir/%!.bam' --threads ${num_threads} ${bamfile}

        barcode_lines=\$(samtools view -H ${bamfile} | grep -P "^@CO" | awk -F'\\t' '{print \$2}')

        for barcode_line in \${barcode_lines}; do
            barcode=\${barcode_line:3}
            output_bam="outdir/\${barcode}.bam"

            if [[ ! -e "\$output_bam" ]]; then
                samtools view -Hb ${bamfile} > \${output_bam}
            fi
        done
    """
}
