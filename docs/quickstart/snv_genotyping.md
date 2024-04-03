*prerequisite: [quickstart](README.md)*

1. Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/snv_genotyping_testdata.tar.gz
    tar -xvf snv_genotyping_testdata.tar.gz
```


2. create params.yaml file:

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
