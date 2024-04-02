process BREAKPOINTMETADATA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(destruct_calls)
    path(destruct_reads)
    path(destruct_library)
    path(destruct_cell_counts)
    path(destruct_cell_counts_yaml)
    path(destruct_vcf)
    path(destruct_vcf_tbi)
    path(lumpy)
    path(svaba)
    path(gridss)
    path(consensus_csv)
    path(consensus_yaml)
    path(metadata_input, stageAs: "metadata_file/*")
  output:
    path("metadata.yaml"), emit: metadata
  script:
    """
        breakpoint_utils breakpoint-generate-per-sample-metadata \
        --destruct ${destruct_calls} --destruct ${destruct_reads} \
        --destruct ${destruct_library} --destruct ${destruct_cell_counts} \
        --destruct ${destruct_cell_counts_yaml}  --destruct ${destruct_vcf} \
        --destruct ${destruct_vcf_tbi} --svaba ${svaba} --lumpy ${lumpy} \
        --gridss ${gridss} --consensus ${consensus_csv} --consensus ${consensus_yaml} \
        --metadata_input ${metadata_input} --metadata_output metadata.yaml
    """
}
