process SVABA {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(normal_bai)
    path(tumor_bam)
    path(tumor_bai)
    path(reference)
    path(reference_fai)
    path(reference_amb)
    path(reference_ann)
    path(reference_bwt)
    path(reference_pac)
    path(reference_sa)
    val(filename)
    val(numcores)
  output:
    path("${filename}.vcf.gz"), emit: vcf
  script:
    """
        svaba run -t ${tumor_bam} -n ${normal_bam} -G ${reference} -z -p ${numcores} -a svaba
        mv svaba.svaba.somatic.sv.vcf.gz ${filename}.vcf.gz
    """
}
