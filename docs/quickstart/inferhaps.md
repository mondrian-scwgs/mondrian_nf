# Infer Haplotypes

*prerequisite: [quickstart](README.md)*

#### Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/haplotype_calling_testdata.tar.gz
    tar -xvf haplotype_calling_testdata.tar.gz
```


#### Create reference.csv file

```
chromosome,regions_vcf,genetic_map
15,<path-to-haplotype_testdata>/ref/ALL.chr15.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz,<path-to-haplotype_testdata>/ref/genetic_map_chr15_combined_b37.txt
```


#### Create params.yaml file:

```
bam: "<path-to-haplotype_testdata>/data/HCC1395BL_chr15.bam"
chromosome_references: "<path-to-workdir>/reference.csv"
reference_fasta: "<path-to-haplotype_testdata>/ref/GRCh37-lite.fa"
output_dir: 'results'
phased_chromosomes: ['chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10', 'chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19', 'chr20', 'chr21', 'chr22', 'chrX']
phased_chromosome_x: 'chrX'
is_female: false
num_samples : 100
confidence_threshold: 0.95
mode: inferhaps
sample_id: SA123
```

#### Run pipeline
```
./nextflow pull mondrian-scwgs/mondrian_nf -r main

./nextflow run mondrian-scwgs/mondrian_nf -r main -params-file params.yaml -resume
```

- to launch using singularity please add: `-profile singularity`
- to launch using singularity and slurm please add: `-profile singularity,slurm`
- to launch using singularity and lsf please add: `-profile singularity,lsf`
- to launch using docker please add: `-profile docker`
- to specify number of jobs: `--max_cpus 45`
