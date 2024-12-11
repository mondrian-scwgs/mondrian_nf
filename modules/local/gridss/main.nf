process GRIDSS {
    time '48h'
    cpus 12
    memory '60 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(tumor_bam)
    path(reference)
    path(reference_fai)
    path(reference_amb)
    path(reference_ann)
    path(reference_bwt)
    path(reference_pac)
    path(reference_sa)
    val(filename)
    val(numcores)
    val(jvm_heap_gb)
  output:
    path("${filename}.vcf.gz"), emit: vcf
  script:
    """
        ls -l 
        gridss.sh \
        --assembly assembly/assembly.bam \
        --reference ${reference} \
        --output ${filename}.vcf.gz \
        --threads ${numcores} \
        --workingdir workingdir \
        --jvmheap ${jvm_heap_gb}g \
        --steps All \
        --labels tumour,normal ${tumor_bam} ${normal_bam}
    """

}
