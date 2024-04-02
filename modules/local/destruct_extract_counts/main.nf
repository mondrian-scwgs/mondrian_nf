process EXTRACTCOUNTS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

    input:
    path(destruct_reads)
    val(filename)

    output:
    path("${filename}.csv.gz"), emit: csv
    path("${filename}.csv.gz.yaml"), emit: yaml

    script:
    """
        breakpoint_utils breakpoint-destruct-extract-cell-counts  \
        --reads ${destruct_reads} \
        --output ${filename}.csv.gz \
    """
}