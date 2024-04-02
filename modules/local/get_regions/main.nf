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
    def chromosomes_arg = ''
    if (chromosomes instanceof nextflow.util.BlankSeparatedList){
        chromosomes_arg = '--chromosomes ' + chromosomes.join(' --chromosomes ')
    } else {
        chromosomes_arg = '--chromosomes ' + chromosomes
    }
    """
    variant_utils generate-intervals --reference ${reference} ${chromosomes_arg} --size ${size} > intervals.txt
    """
}