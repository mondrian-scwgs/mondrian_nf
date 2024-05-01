# Inputs

## Params Yaml:

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

## Samplesheet csv

```
cellid,laneid,flowcellid,fastq1,fastq2
CELLID1,LANE1,FLOWCELL1,<path-to-qc_testdata>/R1.fastq.gz,<path-to-qc_testdata>/R2.fastq.gz
```

## metadata yaml

This is one of the inputs in `input.json` and contains cell and lane level metadata.

1. cells: contains metadata about each cell. center, library_id are required
2. lanes: contains lane level metadata. sample_id is required

Format:

```
meta:
  cells:
    SA1090-A96213A-R22-C43:
      column: 22
      condition: A
      img_col: 68
      index_i5: i5-22
      index_i7: i7-43
      index_sequence: GGGGTT-TAGGAT
      is_control: true
      library_id: 128688A
      pick_met: C1
      primer_i5: GGGGTT
      primer_i7: TAGGAT
      row: 43
      sample_id: SA1090
      sample_type: A
    SA1090-A96213A-R20-C28:
      column: 20
      condition: A
      img_col: 69
      index_i5: i5-22
      index_i7: i7-43
      index_sequence: GGGGTT-TAGGAT
      is_control: true
      library_id: 128688A
      pick_met: C1
      primer_i5: GGGGTT
      primer_i7: TAGGAT
      row: 28
      sample_id: SA1090
      sample_type: A
  lanes:
    FL001:
      L001:
        sequencing_centre: BCCRC
```

# Outputs

## Alignment Metrics

| Column                            | Description                                                                                                                                                            |
|-----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| cell_id                           | label of the cell                                                                                                                                                      |
| fastqscreen_grch37                | number of reads that were classified as human                                                                                                                          |
| fastqscreen_grch37_multihit       | number of reads that were classified as human and something else                                                                                                       |
| fastqscreen_mm10                  | number of reads that were classified as mouse                                                                                                                          |
| fastqscreen_mm10_multihit         | number of reads classified as mouse and something else                                                                                                                 |
| fastqscreen_nohit                 | number of reads with no organism match                                                                                                                                 |
| fastqscreen_salmon                | number of reads that were classified as salmon                                                                                                                         |
| fastqscreen_salmon_multihit       | number of reads that were classified as salmon and something else                                                                                                      |
| fastqscreen_total_reads           | total number of reads calculated during fastqscreen                                                                                                                    |
| estimated_library_size            | scaled total number of mapped reads                                                                                                                                    |
| aligned                           | Coverage based on the number of aligned reads((aligned_read_count * average_read_length)/genome_size )                                                                 |
| paired_duplicate_reads            | number of paired reads that were also marked as duplicate                                                                                                              |
| percent_duplicate_reads           | percentage of duplicate reads                                                                                                                                          |
| total_duplicate_reads             | number of duplicate reads                                                                                                                                              |
| standard_deviation_insert_size    | standard deviation of the insert size between paired reads                                                                                                             |
| total_reads                       | total number of reads, regardless of mapping status                                                                                                                    |
| overlap_with_dups                 | ratio of genome that is covered by at least one read excluding duplicate reads                                                                                         |
| coverage_depth                    | average reads per nucleotide position in the genome                                                                                                                    |
| overlap_without_dups              | ratio of genome that is covered by at least one read                                                                                                                   |
| coverage_breadth                  | percentage of genome covered by some read                                                                                                                              |
| expected                          | Expected coverage based on raw read count ((read_count * average_read_length)/genome_size )                                                                            |
| total_properly_paired             |                                                                                                                                                                        |
| unpaired_duplicate_reads          | number of unpaired duplicated reads                                                                                                                                    |
| unmapped_reads                    | number of unmapped reads                                                                                                                                               |
| unpaired_mapped_reads             | number of unpaired mapped reads                                                                                                                                        |
| total_mapped_reads                | total number of mapped reads                                                                                                                                           |
| mean_insert_size                  | median insert size between paired reads                                                                                                                                |
| paired_mapped_reads               | number of mapped reads that were properly paired                                                                                                                       |
| median_insert_size                | median insert size between paired reads                                                                                                                                |
| overlap_with_all_filters_and_qual | ratio of genome that is covered by at least one read excluding unpaired, duplicate, supplementary and secondary reads                                                  |
| overlap_with_all_filters          | ratio of genome that is covered by at least one read excluding unpaired, duplicate, supplementary and secondary reads, and over 10 mapping quality and 10 base quality |
| is_contaminated                   | boolean to denote contaminated cells                                                                                                                                   |
| fastqscreen_nohit_ratio           | ratio of reads with no organism match                                                                                                                                  |
| fastqscreen_grch37_ratio          | ratio of reads classified as human                                                                                                                                     |
| fastqscreen_mm10_ratio            | ratio of reads classified as mouse                                                                                                                                     |
| fastqscreen_salmon_ratio          | ratio of reads classified as salmon                                                                                                                                    |
| species                           | predicted species of the cell                                                                                                                                          |
| column                            | column of the cell on the nanowell chip                                                                                                                                |
| condition                         | experimental treatment of the cell, includes controls                                                                                                                  |
| img_col                           | column of the cell from the perspective of the microscope                                                                                                              |
| index_i5                          | id of the i5 index adapter sequence                                                                                                                                    |
| index_i7                          | id of the i7 index adapter sequence                                                                                                                                    |
| index_sequence                    | index sequence of the adaptor sequence                                                                                                                                 |
| is_control                        | boolean to denote control cells                                                                                                                                        |
| library_id                        | name of library                                                                                                                                                        |
| pick_met                          | living/dead classification of the cell based on staining usually, C1 == living, C2 == dead                                                                             |
| primer_i5                         | id of the i5 index primer sequence                                                                                                                                     |
| primer_i7                         | id of the i7 index primer sequence                                                                                                                                     |
| row                               | row of the cell on the nanowell chip                                                                                                                                   |
| sample_id                         | name of the sample                                                                                                                                                     |
| sample_type                       | type of the sample                                                                                                                                                     |
| multiplier                        | Multiplier used by hmmcopy                                                                                                                                             |
| MSRSI_non_integerness             | median of segment residuals from segment integer copy number states                                                                                                    |
| MBRSI_dispersion_non_integerness  | median of bin residuals from segment integer copy number states                                                                                                        |
| MBRSM_dispersion                  | median of bin residuals from segment median copy number values                                                                                                         |
| autocorrelation_hmmcopy           | hmmcopy copy autocorrelation                                                                                                                                           |
| cv_hmmcopy                        |                                                                                                                                                                        |
| empty_bins_hmmcopy                | number of empty bins in hmmcopy                                                                                                                                        |
| mad_hmmcopy                       | median absolute deviation of hmmcopy copy                                                                                                                              |
| mean_hmmcopy_reads_per_bin        | mean reads per hmmcopy bin                                                                                                                                             |
| median_hmmcopy_reads_per_bin      | median reads per hmmcopy bin                                                                                                                                           |
| std_hmmcopy_reads_per_bin         | standard deviation value of reads in hmmcopy bins                                                                                                                      |
| total_mapped_reads_hmmcopy        | total mapped reads in all hmmcopy bins                                                                                                                                 |
| total_halfiness                   | summed halfiness penality score of the cell                                                                                                                            |
| scaled_halfiness                  | summed scaled halfiness penalty score of the cell                                                                                                                      |
| mean_state_mads                   | mean value for all median absolute deviation scores for each state                                                                                                     |
| mean_state_vars                   | variance value for all median absolute deviation scores for each state                                                                                                 |
| mad_neutral_state                 | median absolute deviation score of the neutral 2 copy state                                                                                                            |
| breakpoints                       | number of breakpoints, as indicated by state changes not at the ends of chromosomes                                                                                    |
| mean_copy                         | mean hmmcopy copy value                                                                                                                                                |
| state_mode                        | the most commonly occuring state                                                                                                                                       |
| log_likelihood                    | hmmcopy log likelihood for the cell                                                                                                                                    |
| true_multiplier                   | the exact decimal value used to scale the copy number for segmentation                                                                                                 |
| is_s_phase                        |                                                                                                                                                                        |
| is_s_phase_prob                   |                                                                                                                                                                        |
| clustering_order                  | order of the cell in the hierarchical clustering tree                                                                                                                  |
| quality                           |                                                                                                                                                                        |

## hmmcopy params

| columns   | Description |
|-----------|-------------|
| state     |             |
| iteration |             |
| value     |             |
| parameter |             |
| cell_id   |             |

## HMMCopy Reads

| Column             | Description                                                                   |
|--------------------|-------------------------------------------------------------------------------|
| chr                | chromosome                                                                    |
| start              | start position                                                                |
| end                | end position                                                                  |
| reads              | number of reads that start in the bin                                         |
| gc                 | average GC content of all bases in the bin, -1 if N is present                |
| map                | average mappability value of bin                                              |
| cor_gc             | gc-corrected copy number value                                                |
| copy               | final output copy number value                                                |
| valid              | TRUE if reads > 0 & gc > 0, else FALSE                                        |
| ideal              | TRUE if bin is VALID with good mappability and non-outlier gc and read values |
| modal_curve        | value of the gc-correction modal curve given the bin's gc                     |
| modal_quantile     |                                                                               |
| cor_map            | mappability-corrected gc-corrected copy number value                          |
| multiplier         | hmmcopy parameter set used [1..6]                                             |
| state              | the copy number state of the bin                                              |
| cell_id            | label of the cell                                                             |
| is_low_mappability | bool, set to True if the segment has a low mappability score                  |

## HMMCopy Segments

| Column     | Description                         |
|------------|-------------------------------------|
| chr        | chromosome                          |
| start      | start position                      |
| end        | end position                        |
| state      | copy number state                   |
| median     | median copy number value of segment |
| multiplier | hmmcopy parameter set used [1..6]   |
| cell_id    | label of the cell                   |

## GC metrics

The GC metrics are collected by picard's CollectGcMetrics. We run the program with default settings and generate the
following table.

| Column name | Description                        |
|-------------|------------------------------------|
| cell_id     |                                    |
| 0           | NORMALIZED_COVERAGE where GC = 0   |
| 1           | NORMALIZED_COVERAGE where GC = 1   |
| 2           | NORMALIZED_COVERAGE where GC = 2   |
| 3           | NORMALIZED_COVERAGE where GC = 3   |
| ...         |                                    |
| 99          | NORMALIZED_COVERAGE where GC = 99  |
| 100         | NORMALIZED_COVERAGE where GC = 100 |

## Detailed fastqscreen metrics

Thiss csv file stores counts of reads for all possible combinations of:

1. Cell id
2. read end
3. grch37
4. mm10
5. salmon

these files can be found in the alignment tar file output from qc pipeline

| column  |                         Description                          |
|:-------:|:------------------------------------------------------------:|
| cell_id |                       Cell Identifier                        |
| readend | R1 denotes first read and R2 denotes the second read in pair |
| grch37  |                           [0,1,2]                            |
|  mm10   |                           [0,1,2]                            |
| salmon  |                           [0,1,2]                            |
|  count  |  number of reads with the combination of values in rows 1-5  |

| Fastq Screen Flag | Explanation        |
|-------------------|--------------------|
| 0                 | Read does not map  |
| 1                 | Read maps uniquely |
| 2                 | Read multi maps    |

## Merged bam

The merged library bam is the result of merging reads from cells to form a single `pseudobulk` bam file.

**Header:**

The bam file header contains the information about all the cell ids that are included in the bam file in form of
comments with the following format:

```
@CO	CB:SA1090-A96213A-R22-C43
@CO	CB:SA1090-A96213A-R20-C28
```

**Read groups:**

The read groups from per cell bams are preserved

```
@RG ID:${SAMPLE}_${LIBRARY}_${LANE} SM:${SAMPLE}    LB:${LIBRARY}   PL:ILLUMINA CN:${CENTRE}" \
```

So, the readgroups can differentiate based on

- lane id
- library id
- sample id

** Read Tags:**

Each read will also preserve the tags from the originating cell. the lineage of the cell can be traced by the read group
it belongs to and by the `CB` tag in the read.
Additionally, each read will also contain the Organism tag, which will classify the read as human or contaminant.

The tag format in bam file is as follows:

```
FS:Z:mm10_0,salmon_0,grch37_1
```

| Fastq Screen Flag | Explanation        |
|-------------------|--------------------|
| 0                 | Read does not map  |
| 1                 | Read maps uniquely |
| 2                 | Read multi maps    |