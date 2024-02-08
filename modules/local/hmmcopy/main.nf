process HMMCOPY {
    time '24h'
    cpus 2
    memory '12 GB'
    label 'process_high'

  input:
    tuple(
      val(cell_id),
      path(bamfile),
      path(baifile),
      path(gc_wig),
      path(map_wig),
      path(reference),
      path(reference_fai),
      path(alignment_metrics),
      path(alignment_metrics_yaml),
      path(repeats_satellite_regions),
      path(quality_classifier_training_data),
      val(chromosomes),
      val(map_cutoff)
    )
  output:
    tuple(
        val(cell_id),
        path("${cell_id}_reads.csv.gz"),
        path("${cell_id}_reads.csv.gz.yaml"),
        path("${cell_id}_metrics.csv.gz"),
        path("${cell_id}_metrics.csv.gz.yaml"),
        path("${cell_id}_params.csv.gz"),
        path("${cell_id}_params.csv.gz.yaml"),
        path("${cell_id}_segments.csv.gz"),
        path("${cell_id}_segments.csv.gz.yaml"),
        path("${cell_id}_hmmcopy_data.tar.gz"),
        path("segments.pdf"),
        path("bias.pdf")
    )
  script:
    def chromosomes = "--chromosomes " + chromosomes.join(" --chromosomes ")
    """
        cp ${quality_classifier_training_data} training_data.h5
        hmmcopy_utils run-cell-hmmcopy \
        --bam_file ${bamfile} \
        --gc_wig_file ${gc_wig} \
        --map_wig_file ${map_wig} \
        --alignment_metrics ${alignment_metrics} \
        ${chromosomes} \
        --metrics ${cell_id}_metrics.csv.gz \
        --params ${cell_id}_params.csv.gz \
        --reads ${cell_id}_reads.csv.gz \
        --segments ${cell_id}_segments.csv.gz \
        --output_tarball ${cell_id}_hmmcopy_data.tar.gz \
        --exclude_list ${repeats_satellite_regions} \
        --reference ${reference} \
        --segments_output segments.pdf \
        --bias_output bias.pdf \
        --tempdir output \
        --map_cutoff ${map_cutoff} \
        --quality_classifier_training_data training_data.h5
        rm training_data.h5
    """
}
