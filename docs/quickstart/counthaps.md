*prerequisite: [quickstart](README.md)*

1. Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/haplotype_calling_testdata.tar.gz
    tar -xvf haplotype_calling_testdata.tar.gz
```


3. create params.yaml file:

```
tumor_bam: "<path-to-haplotype_testdata>/data/merged_reheader.bam"
haplotypes_csv: "<path-to-haplotype_testdata>/data/haps.csv.gz"
chromosomes: ["15"]
snp_positions: "<path-to-haplotype_testdata>/ref/thousand_genomes_snps.tsv"
reference_fasta: "<path-to-haplotype_testdata>/ref/GRCh37-lite.fa"
gap_table: "<path-to-haplotype_testdata>/ref/hg19_gap.txt.gz"
mode: "counthaps"
numcores: 8
sample_id: "SA123"
output_dir: "results"
metadata_input: "<path-to-haplotype_testdata>/data/metadata.yaml"
```

4. run pipeline
```
./nextflow pull mondrian-scwgs/mondrian_nf -r main

./nextflow run mondrian-scwgs/mondrian_nf -r main -params-file params.yaml -resume
```

to launch using singularity please add: `-profile singularity`
to launch using singularity and slurm please add: `-profile singularity,slurm`
to launch using singularity and lsf please add: `-profile singularity,lsf`
to launch using docker please add: `-profile docker`
to specify number of jobs: `--max_cpus 45`
