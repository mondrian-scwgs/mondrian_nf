process GETREGIONS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'


    input:
    path(reference)
    val(chromosomes)
    val(size)

    output:
    path('intervals.txt')

    script:
    chromosomes_arg = '--chromosomes ' + chromosomes.join(' --chromosomes ')
    """
    variant_utils generate-intervals --reference ${reference} ${chromosomes_arg} --size ${size} > intervals.txt
    """
}