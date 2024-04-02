process MERGEPILEUPS {
    time '48h'
    cpus 12
    memory '12 GB'
    label 'process_high'

  input:
    path(input_tables)
    path(reference_dict)
    val(filename)
  output:
    path("${filename}.tsv"), emit: tsv
  script:
    def inputs = ''
    if (input_tables instanceof nextflow.util.BlankSeparatedList){
        inputs = '-I ' + input_tables.join(' -I ')
    } else {
        inputs = '-I ' + input_tables
    }
    """
        set -e
        gatk GatherPileupSummaries \
        --sequence-dictionary ${reference_dict} \
        ${inputs} \
        -O ${filename}.tsv
    """
}
