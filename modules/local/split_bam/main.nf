process SPLITBAM_TASK {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_high'

  input:
    path(bamfile)
    val(num_threads)
  output:
    path("outdir/*bam"), emit: bams, optional: true
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

workflow SPLITBAM {
    take:
    bamfile
    num_threads

    main:
    SPLITBAM_TASK(bamfile, num_threads)

    split_bams = SPLITBAM_TASK.out.bams
        .flatten()
        .map { bam_file ->
            def cell_id = bam_file.baseName
            tuple(cell_id, bam_file)}

    emit:
    split_bams
}
