process VCF2MAF {
    time '48h'
    cpus 1
    memory '12 GB'
    label 'process_low'

  input:
    path(vcf_file)
    path(tumour_bam)
    path(normal_bam)
    path(vep_ref)
    val(vep_fasta_suffix)
    val(ncbi_build)
    val(cache_version)
    val(species)
    val(filename)
  output:
    path("${filename}.maf"), emit: maf
  script:
    """
        mkdir vep_ref_dir
        tar -xvf ${vep_ref} --directory vep_ref_dir

        zcat ${vcf_file} > uncompressed.vcf

        rm -f uncompressed.vep.vcf

        vcf2maf uncompressed.vcf temp.maf \
          vep_ref_dir/vep/${vep_fasta_suffix} \
          vep_ref_dir/vep ${ncbi_build} ${cache_version} ${species}

        variant_utils update-maf-ids --input temp.maf --tumour_bam ${tumour_bam} --normal_bam ${normal_bam} --output ${filename}.maf

    """

}
