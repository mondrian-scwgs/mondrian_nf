process SPLIT_BULK_BAM {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_high'

  input:
    path(bamfile)

  output:
    path("outdir/*.bam"), emit: bams, optional: true

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

        mkdir tmpdir outdir
        samtools split -d CB -M \$MAX_BARCODES --output-fmt bam -f 'tmpdir/%!.bam' --threads ${task.cpus} ${bamfile}

        for barcode_line in \${barcode_lines}; do
            barcode=\${barcode_line:3}
            tmp_bam="tmpdir/\${barcode}.bam"

            if [[ ! -e "\$tmp_bam" ]]; then
                samtools view -Hb ${bamfile} > \${tmp_bam}
            fi

            { samtools view -H "\$tmp_bam" | grep -v "^@CO"; printf "@CO\t%s\n" "\${barcode_line}"; } > "tmpdir/\${barcode}.header.sam"
            samtools reheader "tmpdir/\${barcode}.header.sam" "\$tmp_bam" > "outdir/\${barcode}.bam"
            rm "tmpdir/\${barcode}.header.sam"
        done
        rm -r tmpdir
    """
}
