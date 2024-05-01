# Inputs:

## params yaml
```
vcf_files: ["<path-to-snvgenotyping_testdata>/snv_genotyping/merged_sorted.vcf.gz"]
bam_file: "snv_genotyping/merged.bam"
reference_fasta: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.fa"
mode: "snv_genotyping"
metadata_input: "<path-to-snvgenotyping_testdata>/snv_genotyping/metadata.yaml"
numlines: 5000
numcores: 8
sample_id: "SA123"
output_dir: "results"
```


# Outputs


## pysam genotyper


| Column     | Description                                             | 
|------------|----------------------------------------------------------|
| chrom      | Chromosome                                               |
| pos        | position in genome                                       |
| ref        | reference allele as called in snv vcf                    |
| alt        | alternate allele as called in snv vcf                    |
| cell_id    | cell barcode                                             |
| ref_counts | count of reads that support the reference allele in cell |
| alt_counts | count of reads that support the alternate allele in cell |


## vartrix

| Column     | Description                                              | 
|------------|----------------------------------------------------------|
| chromosome | Chromosome                                               |
| position   | position in genome                                       |
| cell_id    | cell barcode                                             |
| ref_counts | count of reads that support the reference allele in cell |
| alt_counts | count of reads that support the alternate allele in cell |
