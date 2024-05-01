
# Inputs



## params yaml:

```
normal: "<path-to-breakpoint_testdata>/normal.bam"
tumor: "<path-to-breakpoint_testdata>/medium.bam"
metadata: "<path-to-breakpoint_testdata>/metadata.yaml"
chromosomes: ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"]
reference: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.fa"
reference_gtf: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.gtf"
reference_dgv: "<path-to-mondrian-ref-20-22>/human/dgv.txt"
repeats_satellite_regions: "<path-to-mondrian-ref-20-22>/human/repeats.satellite.regions"
sample_id: "T2-T-A"
numcores: 8
mode: "breakpoint"
output_dir: "results"
```


# Outputs

## consensus 

| File                 | Description                                   |
|----------------------|-----------------------------------------------|
|chromosome_1          |Chromosome for breakend 1                      |
|position_1            |Position for breakend 1                        |
|strand_1              |Strand for breakend 1                          |
|chromosome_2          |Chromosome for breakend 2                      |
|position_2            |Position for breakend 2                        |
|strand_2              |Strand for breakend 2                          |
|type                  |Type of breakpoint, see table below for legend |
|breakpoint_id         |                                               |
|caller                |comma delimited list of callers                |
|grouped_breakpoint_id |auto generated unique id                       |
|sample_id             |Sample Identifier                              |


**Breakpoint types:**

|Type          | Description|
|--------------|-------------------|
|inversion     |++,--|
|duplication   |-+|
|deletion      |+-|
|translocation | 2 different chromosomes|
|BND           ||


## Destruct library

| File            | Description                                                       |
|-----------------|-------------------------------------------------------------------|
|prediction_id    |auto generated id for each call                                    |
|num_reads        |number of supporting reads                                         |
|num_unique_reads |Number of reads for this dataset, potential PCR duplicates removed |
|library          |ID of the dataset                                                  |

## Destruct reads

| File         | Description                                             |
|--------------|---------------------------------------------------------|
|prediction_id |Unique identifier of the breakpoint prediction           |
|library_id    |ID of the dataset                                        |
|fragment_id   |ID of the discordant read                                |
|read_end      |End of the paired end read                               |
|seq           |Read sequence                                            |
|qual          |Read quality                                             |
|comment       |Read comment                                             |
|filtered      |The read was filtered prior to finalizing the prediction |

## destruct table

| Column              | Description                                                        |
|---------------------|--------------------------------------------------------------------|
| prediction_id       | Unique identifier of the breakpoint prediction                     |
| chromosome_1        | Chromosome for breakend 1                                          |
| strand_1            | Strand for breakend 1                                              |
| position_1          | Position of breakend 1                                             |
| gene_id1            | Ensembl gene id for gene at or near breakend 1                     |
| gene_name1          | Name of the gene at or near breakend 1                             |
| gene_location1      | Location of the gene with respect to the breakpoint for breakend 1 |
| chromosome_2        | Chromosome for breakend 2                                          |
| strand_2            | Strand for breakend 2                                              |
| position_2          | Position of breakend 2                                             |
| gene_id2            | Ensembl gene id for gene at or near breakend 2                     |
| gene_name2          | Name of the gene at or near breakend 2                             |
| gene_location2      | Location of the gene with respect to the breakpoint for breakend 2 |
| type                | Breakpoint orientation type deletion                               |
| num_reads           | Total number of discordant reads                                   |
| num_unique_reads    | Total number of discordant reads, potential PCR duplicates removed |
| num_split           | Total number of discordant reads split by the breakpoint           |
| num_inserted        | Number of untemplated nucleotides inserted at the breakpoint       |
| homology            | Sequence homology at the breakpoint                                |
| dgv_ids             | Database of genomic variants annotation for germline variants      |
| sequence            | Sequence as predicted by discordant reads and possibly split reads |
| inserted            | Nucleotides inserted at the breakpoint                             |
| mate_score          | average score of mate reads aligning as if concordant              |
| template_length_1   | length of region to which discordant reads align at breakend 1     |
| template_length_2   | length of region to which discordant reads align at breakend 2     |
| log_cdf             | mean cdf of discordant read alignment likelihood                   |
| log_likelihood      | mean likelihood of discordant read alignments                      |
| template_length_min | minimum of template_length_1 and template_length_2                 |


## Gridss vcf

Please see [GRIDSS](https://github.com/PapenfussLab/gridss)

## lumpy vcf

Please see [LUMPY](https://github.com/arq5x/lumpy-sv)

## svaba vcf

Please see [SVABA](https://github.com/walaj/svaba)
