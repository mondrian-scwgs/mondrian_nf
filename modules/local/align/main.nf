process ALIGN {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
    tuple(
      val(cell_id), val(lanes), val(flowcells), path(fastqs1), path(fastqs2),
      path(human_reference), val(human_reference_version),
      path(human_reference_fai),path(human_reference_amb),path(human_reference_ann),path(human_reference_bwt),path(human_reference_pac),path(human_reference_sa),
      path(mouse_reference), val(mouse_reference_version),
      path(mouse_reference_fai),path(mouse_reference_amb),path(mouse_reference_ann),path(mouse_reference_bwt),path(mouse_reference_pac),path(mouse_reference_sa),
      path(salmon_reference), val(salmon_reference_version),
      path(salmon_reference_fai),path(salmon_reference_amb),path(salmon_reference_ann),path(salmon_reference_bwt),path(salmon_reference_pac),path(salmon_reference_sa),
      path(metadata)
    )
  output:
    tuple(
        val(cell_id),
        path("aligned.bam"),
        path("aligned.bam.bai"),
        path("metrics.csv.gz"),
        path("metrics.csv.gz.yaml"),
        path("${cell_id}_gc_metrics.csv.gz"),
        path("${cell_id}_gc_metrics.csv.gz.yaml"),
        path("${cell_id}.tar.gz")
    )
  script:
    def lanes = lanes.join(' ')
    def flowcells = flowcells.join(' ')
    """

        fastqs_cmd=`python -c 'x=["${lanes}","${flowcells}","${fastqs1}","${fastqs2}"];x=[v.split() for v in x];x=[",".join(v) for v in zip(*x)];x=" --fastq_pairs ".join(x);print(x)'`

        alignment_utils alignment \
        --fastq_pairs \${fastqs_cmd} \
        --metadata_yaml ${metadata} \
        --reference human,${human_reference_version},${human_reference} \
        --supplementary_references mouse,${mouse_reference_version},${mouse_reference} \
        --supplementary_references salmon,${salmon_reference_version},${salmon_reference} \
        --tempdir tempdir \
        --adapter1 CTGTCTCTTATACACATCTCCGAGCCCACGAGAC \
        --adapter2 CTGTCTCTTATACACATCTGACGCTGCCGACGA \
        --cell_id $cell_id \
        --wgs_metrics_mqual 20 \
        --wgs_metrics_bqual 20 \
        --wgs_metrics_count_unpaired false \
        --bam_output aligned.bam \
        --metrics_output metrics.csv.gz \
        --metrics_gc_output ${cell_id}_gc_metrics.csv.gz \
        --tar_output ${cell_id}.tar.gz \
        --num_threads ${task.cpus}

        rm -rf tempdir
    """
}
