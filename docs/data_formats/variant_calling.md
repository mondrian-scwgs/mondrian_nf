# Inputs:

## params yaml

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


# Outputs:

## Maf file with all samples

Consensus calls from each sample are concatenated to generate this file. Please see [Maf file format](https://docs.gdc.cancer.gov/Data/File_Formats/MAF_Format/) for detailed breakdown of maf format. 

## Vcf file with all samples

Consensus calls from each sample are concatenated to generate this file. Please see [Vcf file format](https://samtools.github.io/hts-specs/VCFv4.2.pdf) for detailed specification of vcf format. 
The vcf format is a very stripped down version.

## consensus vcf

Vcf file with consensus calls. Consensus is defined as follows:

**snv**
Snv Positions called by 2 or more callers out of 3 (museq, strelka and mutect)

**indel**
Union set of indel Positions called by strelka and mutect)

## consensus maf

Maf version of the consensus vcf file

## museq vcf
Please refer to [museq](https://github.com/shahcompbio/mutationseq) and vcf header for details

## mutect vcf
Please refer to [mutect](https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2) and vcf header for details


## strelka vcf
Please refer to [strelka](https://github.com/Illumina/strelka) and vcf header for details
