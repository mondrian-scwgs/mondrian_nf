process BWA_MEM_BULK {
    tag "$sample_id"
    label 'process_high'

    input:
    tuple val(sample_id), path(trimmed_r1), path(trimmed_r2)
    path(reference)
    path(reference_fai)
    path(reference_amb)
    path(reference_ann)
    path(reference_bwt)
    path(reference_pac)
    path(reference_sa)
    path(rg_header)

    output:
    tuple val(sample_id), path("${sample_id}_aligned.sam")

    script:
    """
    bwa mem \
        -C \
        -M \
        -t ${task.cpus} \
        -H ${rg_header} \
        ${reference} \
        ${trimmed_r1} \
        ${trimmed_r2} \
        > ${sample_id}_aligned.sam
    """
}
