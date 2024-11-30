process READORIENTATIONMODEL {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(f1r2)
  output:
    path("artifact-priors.tar.gz"), emit: artifact_priors
  script:
    def inputs = "-I " + f1r2.join(" -I ")
    """
        set -e
        echo ${inputs} > arguments_list

        mkdir tempdir

        gatk --java-options "-Xmx4G" LearnReadOrientationModel \
            --arguments_file arguments_list \
            -O artifact-priors.tar.gz \
            --tmp-dir tempdir
    """
}
