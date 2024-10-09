process BREAKPOINTCONSENSUS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

    input:
    path(destruct)
    path(lumpy)
    path(gridss)
    path(svaba)
    path(blacklist)
    val(blacklist_flag)
    val(sample_id)
    val(filename)
    val(region)

    output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml

    script:
    def blacklist_arg = blacklist_flag ? "--blacklist_file "+blacklist : ""
    """
        mkdir tempdir
        breakpoint_utils breakpoint-consensus \
        --destruct ${destruct} \
        --lumpy ${lumpy} --svaba ${svaba} \
        --gridss ${gridss} --consensus_output ${filename}.csv.gz --sample_id ${sample_id} \
        --tempdir tempdir \
        --region ${region} \
        ${blacklist_arg}
    """
}
