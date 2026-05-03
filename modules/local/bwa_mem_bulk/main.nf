process BWA_MEM_BULK {
    tag "${sample_id}_chunk${chunk_id}"
    label 'process_high'

    input:
    tuple val(sample_id), val(chunk_id), path(trimmed_r1), path(trimmed_r2)
    path(reference)
    path(reference_fai)
    path(bwa_indices)
    path(rg_header)

    output:
    tuple val(sample_id), val(chunk_id), path("${sample_id}_chunk${chunk_id}_aligned.sam")

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
        > ${sample_id}_chunk${chunk_id}_aligned.sam
    """
}
