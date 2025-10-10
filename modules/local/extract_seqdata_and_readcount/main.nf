process EXTRACTSEQDATAANDREADCOUNT {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    tuple(
      val(cell_id),
      path(bam)
    )
    path(snp_positions)
    path(segments)
    path(haplotypes)
    val(chromosomes)
  output:
    path("allele_counts.csv.gz"), emit: csv
    path("allele_counts.csv.gz.yaml"), emit: yaml
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        samtools index ${bam}

        cellid=\$(basename ${bam})
        cellid="\${cellid%.*}"

        mkdir -p readcount_temp seqdata_temp

        haplotype_utils extract-seqdata --bam ${bam} \
        --snp_positions ${snp_positions} \
        --output seqdata_temp/output.h5 \
        --tempdir seqdata_temp \
        ${chromosomes} \
        --cell_id \${cellid}

        haplotype_utils haplotype-allele-readcount \
        --seqdata seqdata_temp/output.h5 \
        --segments ${segments} \
        --haplotypes ${haplotypes} \
        --output allele_counts.csv.gz \
        --tempdir readcount_temp \
        --skip_header \
    """
}
