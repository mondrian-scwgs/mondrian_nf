# Breakpoint

*prerequisite: [quickstart](README.md)*

#### Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/breakpoint_calling_testdata.tar.gz
    tar -xvf breakpoint_calling_testdata.tar.gz
```


#### Create params.yaml file:

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
