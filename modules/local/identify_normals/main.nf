process IDENTIFYNORMALS {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(reads)
    path(reads_yaml)
    path(metrics)
    path(metrics_yaml)
    path(blacklist)
    val(remove_blacklist)
    val(relative_aneuploidy_threshold)
    val(ploidy_threshold)
    val(allowed_aneuploidy_score)
    val(filename)
  output:
    path("${filename}.yaml"), emit: normal_yaml
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml

  script:
    def blacklist_arg = blacklist ? "--blacklist_file "+blacklist : ""
    """
        normalizer_utils identify-normal-cells \
        --reads_data ${reads} \
        --metrics_data ${metrics} \
        --output_yaml ${filename}.yaml \
        --output_csv ${filename}.csv.gz \
        --relative_aneuploidy_threshold ${relative_aneuploidy_threshold} \
        --ploidy_threshold ${ploidy_threshold} \
        --allowed_aneuploidy_score ${allowed_aneuploidy_score} \
        ${blacklist_arg}
    """

}
