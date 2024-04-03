*prerequisite: [quickstart](README.md)*

1. Download test data set

```
    wget https://mondriantestdata.s3.amazonaws.com/variant_calling_testdata.tar.gz
    tar -xvf variant_calling_testdata.tar.gz
```


2. create params.yaml file:

```
normal: "<path-to-variant_testdata>/normal_realign.bam"
tumor: "<path-to-variant_testdata>/variants_realign.bam"
metadata: "<path-to-variant_testdata>/metadata.yaml"
chromosomes: ["22"]
reference: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.fa"
reference_dict: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.dict"
panel_of_normals: "<path-to-mondrian-ref-20-22>/human/small_exac_common_3.vcf.gz"
variants_for_contamination: "<path-to-mondrian-ref-20-22>/human/small_exac_common_3.vcf.gz"
gnomad: "<path-to-mondrian-ref-20-22>/human/gnomad.vcf.gz"
realignment_index_bundle: "<path-to-mondrian-ref-20-22>/human/GRCh37-lite.fa.img"
vep_ref: "<path-to-mondrian-ref-20-22>/vep.tar"
vep_fasta_suffix: "homo_sapiens/99_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz"
ncbi_build: "GRCh37"
cache_version: "99"
species: "homo_sapiens"
sample_id: "SA123T"
numcores: 1
mode: 'variant'
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
