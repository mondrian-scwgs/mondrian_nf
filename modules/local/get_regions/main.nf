process GETREGIONS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'


    input:
    file reference
    val chromosome
    val size

    output:
    tuple(val(chromosome), path('intervals.txt'))

    script:
    """
    reference_utils get-intervals \
        --reference ${reference} \
        --output intervals.txt \
        --chromosomes ${chromosome} \
        --interval_size ${size}
    """
}