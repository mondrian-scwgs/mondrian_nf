process ADD_CB_TO_FASTQ {
    tag "$cell_id"
    label 'process_low'

    input:
    tuple val(cell_id), val(readgroup_id), path(fastq1), path(fastq2)

    output:
    tuple val(cell_id), val(readgroup_id), path("${cell_id}_${readgroup_id}_R1.tagged.fastq.gz"), path("${cell_id}_${readgroup_id}_R2.tagged.fastq.gz")

    script:
    """
    add_cb_to_fastq.py \
        --input_r1 ${fastq1} \
        --input_r2 ${fastq2} \
        --output_r1 ${cell_id}_${readgroup_id}_R1.tagged.fastq.gz \
        --output_r2 ${cell_id}_${readgroup_id}_R2.tagged.fastq.gz \
        --cell_id ${cell_id} \
        --rg_id ${readgroup_id}
    """
}
