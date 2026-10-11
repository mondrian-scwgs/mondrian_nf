# Mouse reference for variant calling

* This page covers the resources needed to run the variant calling pipeline on mouse data (`GRCm38`/`mm10`)
* There is no panel of normals, gnomad or common variant set for mouse. These params are optional and should be left out
* The normal and tumor bams must be aligned to the same fasta that is passed as `reference`

### Fasta and indexes

The vep cache from ensembl uses chromosome names without the `chr` prefix. Using the ensembl fasta for alignment and for
variant calling keeps the chromosome names consistent across the pipeline.

```
mkdir mouse && cd mouse
singularity run --bind $PWD reference_builder.sif wget http://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
singularity run --bind $PWD reference_builder.sif gunzip Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
mv Mus_musculus.GRCm38.dna.primary_assembly.fa GRCm38.fa

singularity run --bind $PWD reference_builder.sif samtools faidx GRCm38.fa
singularity run --bind $PWD reference_builder.sif gatk CreateSequenceDictionary -R GRCm38.fa -O GRCm38.dict
```

### Realignment index bundle (optional)

Used by the mutect alignment artifact filter. Built from the fasta, so it is available for any species.

```
singularity run --bind $PWD variant_calling.sif gatk BwaMemIndexImageCreator -I GRCm38.fa -O GRCm38.fa.img
```

### vep cache

The below links may change. In such cases surf through: http://ftp.ensembl.org/pub

Release 102 is the last ensembl release for GRCm38. For GRCm39 use release 105 and update the paths accordingly.

```
mkdir vep && cd vep
wget http://ftp.ensembl.org/pub/release-102/variation/vep/mus_musculus_vep_102_GRCm38.tar.gz
wget http://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz

tar -xvf mus_musculus_vep_102_GRCm38.tar.gz
rm mus_musculus_vep_102_GRCm38.tar.gz
gunzip Mus_musculus.GRCm38.dna.primary_assembly.fa.gz

mv Mus_musculus.GRCm38.dna.primary_assembly.fa mus_musculus/102_GRCm38/
cd ../

singularity run --bind $PWD reference_builder.sif bgzip vep/mus_musculus/102_GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa
singularity run --bind $PWD reference_builder.sif samtools faidx vep/mus_musculus/102_GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
tar -cvf vep.tar vep
```

### params yaml

```
normal: "<path-to-normal-bam>"
tumor: "<path-to-tumor-bam>"
chromosomes: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "X", "Y"]
reference: "<path-to-mouse-ref>/mouse/GRCm38.fa"
reference_dict: "<path-to-mouse-ref>/mouse/GRCm38.dict"
realignment_index_bundle: "<path-to-mouse-ref>/mouse/GRCm38.fa.img"
vep_ref: "<path-to-mouse-ref>/vep.tar"
vep_fasta_suffix: "mus_musculus/102_GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz"
ncbi_build: "GRCm38"
cache_version: "102"
species: "mus_musculus"
sample_id: "<sample-id>"
numcores: 1
mode: 'variant'
output_dir: "results"
```

### Notes

* Without a panel of normals and a germline resource, mutect relies on the matched normal alone to remove germline
variants and recurrent artifacts. The normal should come from the same animal or strain as the tumor
* A panel of normals built from mouse normals with gatk `CreateSomaticPanelOfNormals` can be passed as `panel_of_normals`
