process DESTRUCT {
    time '48h'
    cpus 12
    memory '96 GB'
    label 'process_high'

  input:
    path(normal_bam)
    path(normal_bai)
    path(tumor_bam)
    path(tumor_bai)
    path(reference)
    path(reference_fai)
    path(reference_1_ebwt)
    path(reference_2_ebwt)
    path(reference_3_ebwt)
    path(reference_4_ebwt)
    path(reference_rev_1_ebwt)
    path(reference_rev_2_ebwt)
    path(reference_dgv)
    path(reference_gtf)
    path(repeats_satellite_regions)
    val(filename)
    val(numcores)
  output:
    path("${filename}_breakpoint_table.csv"), emit: table
    path("${filename}_breakpoint_library_table.csv"), emit: library
    path("${filename}_breakpoint_read_table.csv"), emit: read
  script:
    """
        echo "genome_fasta = '${reference}'; genome_fai = '${reference_fai}'; gtf_filename = '${reference_gtf}'" > config.py

        destruct run \$(dirname ${reference}) \
        ${filename}_breakpoint_table.csv ${filename}_breakpoint_library_table.csv \
        ${filename}_breakpoint_read_table.csv \
        --bam_files ${tumor_bam} ${normal_bam} \
        --lib_ids tumour normal \
        --tmpdir tempdir --pipelinedir pipelinedir --submit local --config config.py --loglevel DEBUG --maxjobs ${numcores}
    """

}
