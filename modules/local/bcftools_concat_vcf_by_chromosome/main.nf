process BCFTOOLSCONCATVCFBYCHROMOSOME {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'


    input:
      tuple(
        val(chromosome),
        path(vcf_files, stageAs: "?/*"),
        path(csi_files, stageAs: "?/*")
      )

    output:
      tuple(
        val(chromosome),
        path("merged_sorted.vcf.gz"),
        path("merged_sorted.vcf.gz.csi")
      )

    script:
    def infiles_arg = ''
    if (vcf_files instanceof nextflow.util.BlankSeparatedList){
        infiles_arg = vcf_files.join(' ')
    } else {
        infiles_arg = vcf_files
    }
    """
        bcftools concat -a -O z -o merged.vcf.gz ${infiles_arg}
        vcf-sort merged.vcf.gz > merged_sorted.vcf
        bgzip merged_sorted.vcf -c > merged_sorted.vcf.gz
        tabix -f -p vcf merged_sorted.vcf.gz
        bcftools index merged_sorted.vcf.gz

    """

}