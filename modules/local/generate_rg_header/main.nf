process GENERATE_RG_HEADER {
    tag "$sample_id"
    label 'process_low'

    input:
    path(samplesheet)
    val(sample_id)

    output:
    path("${sample_id}_rg_header.txt"), emit: header

    script:
    """
    generate_rg_header.py \
        --samplesheet ${samplesheet} \
        --output ${sample_id}_rg_header.txt
    """
}
