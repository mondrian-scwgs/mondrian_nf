*prerequisite: [quickstart](README.md)*

1. Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/normalizer_testdata.tar.gz
    tar -xvf normalizer_testdata.tar.gz
```


2. create params.yaml file:

```
reads: "<path-to-normalizer_testdata>/reads.csv.gz"
metrics: "<path-to-normalizer_testdata>/metrics.csv.gz"
bam: "<path-to-normalizer_testdata>/data.bam"
metadata: "<path-to-normalizer_testdata>/metadata.yaml"
blacklist: "<path-to-normalizer_testdata>/normalizer_blacklist.csv.gz"
qc_only: false
chromosomes: ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y"]
mode: "normalizer"
sample_id: "SAMP123"
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
