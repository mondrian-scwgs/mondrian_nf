process GENERATEBARCODES {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'


    input:
    path(bamfile)
    path(baifile)
    val(filename)
    output:
    path(filename)
    script:
    """
        snv_genotyping_utils generate-cell-barcodes --bamfile ${bamfile} --output ${filename}
    """
}