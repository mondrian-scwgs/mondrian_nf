# QC 

*prerequisite: [quickstart](README.md)*

#### Download test data set

```
wget https://mondriantestdata.s3.amazonaws.com/qc_testdata.tar.gz
tar -xvf qc_testdata.tar.gz
```

#### Create fastqs.csv file:
```
cellid,laneid,flowcellid,fastq1,fastq2
SA1090-A96213A-R20-C28,L001,FL001,<path-to-qc_testdata>/SA1090-A96213A-R20-C28_1.fastq.gz,<path-to-qc_testdata>/SA1090-A96213A-R20-C28_2.fastq.gz
SA1090-A96213A-R22-C43,L001,FL001,<path-to-qc_testdata>/SA1090-A96213A-R22-C43_1.fastq.gz,<path-to-qc_testdata>/SA1090-A96213A-R22-C43_2.fastq.gz
```


#### Create params.yaml file:

```

metadata: "<path-to-alignment_testdata>/metadata.yaml"
chromosomes: ["20","21","22"]
gc_wig: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.gc.ws_500000.wig"
map_wig: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.map.ws_125_to_500000.wig"
quality_classifier_training_data: "<path-to-mondrian-ref-20-22>/human/classifier_training_data.h5"
repeats_satellite_regions: "<path-to-mondrian-ref-20-22>/human/repeats.satellite.regions"
human_reference: '<path-to-mondrian-ref-20-22>/human/GRCh37-lite.fa'
human_reference_version: 'grch37'
mouse_reference: '<path-to-mondrian-ref-20-22>/mouse/mm10_build38_mouse.fasta'
mouse_reference_version: 'mm10'
salmon_reference: '<path-to-mondrian-ref-20-22>/salmon/GCF_002021735.1_Okis_V1_genomic.fna'
salmon_reference_version: 'salmon'
fastqs: '<path-to-workdir>/fastqs.csv'
sample_id: SAMP123
output_dir: 'results/'
mode: 'qc'
```

#### Run
```
./nextflow pull mondrian-scwgs/mondrian_nf -r main

./nextflow run mondrian-scwgs/mondrian_nf -r main -params-file params.yaml -resume
```

- to launch using singularity please add: `-profile singularity`
- to launch using singularity and slurm please add: `-profile singularity,slurm`
- to launch using singularity and lsf please add: `-profile singularity,lsf`
- to launch using docker please add: `-profile docker`
- to specify number of jobs: `--max_cpus 45`
