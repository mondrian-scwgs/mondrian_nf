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
        MAX_BARCODES=5200

        ulimit -n \$((MAX_BARCODES + 20))

        barcode_lines=\$(samtools view -H ${bamfile} | grep "^@CO" | awk -F'\\t' '{print \$2}')

        num_barcodes=\$(echo "\${barcode_lines}" | wc -l)
        if [[ \$num_barcodes -gt \$MAX_BARCODES ]]; then
            echo "Error: Number of barcodes (\$num_barcodes) exceeds the maximum allowed (\$MAX_BARCODES)." >&2
            exit 1
        fi

        mkdir outdir
        samtools split -d CB -M \$MAX_BARCODES --output-fmt bam -f 'outdir/%!.bam' --threads ${num_threads} ${bamfile}

        for barcode_line in \${barcode_lines}; do
            barcode=\${barcode_line:3}
            output_bam="outdir/\${barcode}.bam"

            if [[ ! -e "\$output_bam" ]]; then
                samtools view -Hb ${bamfile} > \${output_bam}
            fi
        done
    """
}
