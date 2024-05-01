# QC

QC analysis runs the following:

- Fastqc
- Trim galore
- bwa mem
- picard Mark Duplicates
- hmmcopy
- Quality and cell cycle classifiers


Alignment also runs the following to collect metrics about the aligned data:
- picard InsertWgsMetrics
- picard WgsMetrics
- samtools flagstat


The analysis takes in csv samplesheet as input and generates one bam file with reads tagged with their corresponding cell ids. 

![](https://lucid.app/publicSegments/view/a0884cb4-a4ff-4696-990f-53c28276a254/image.png)
![](https://lucid.app/publicSegments/view/87a1a33b-d433-4d79-8f50-e75ba3c8db0b/image.png)


## Input Data Format:

The input to the pipeline is a json file.

Please see [QC samplesheet](data_formats/qc.md#samplesheet-csv) for detailed explanation. 



### Output Data Format:

The pipeline will generate a bam file and csv metrics files, the outputs will be stored in the output directory provided at run time. 

The pipeline generates the following output files:

| Output File                                | Description                                                                                                                                   |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| alignment_gc_metrics.csv.gz                | per cell GC metrics in csv format. Please see [Alignment GC Metrics Csv](data_formats/alignment.md#gc-metrics)                                |
| alignment_gc_metrics.csv.gz.yaml           | metadata for GC metrics csv. Please refer to [csverve](https://csverve.readthedocs.io/en/latest/)                                             |
| alignment_metrics.csv.gz                   | per cell alignment related metrics in csv format. Please see [Alignment Metrics Csv](data_formats/alignment.md#alignment-metrics)             |
| alignment_metrics.csv.gz.yaml              | metadata for metrics csv. Please refer to [csverve](https://csverve.readthedocs.io/en/latest/)                                                |
| alignment_metrics.tar.gz                   | compressed tar file with some miscellaneous metrics and plots                                                                                 |
| all_cells_bulk.bam                         | merged bam with all cells that pass filtering. Please see [Merged Bam Format](data_formats/alignment.md#merged-bam)                           |
| all_cells_bulk.bam.bai                     | bam index                                                                                                                                     |
| all_cells_bulk_contaminated.bam            | merged bam with all cells that do not pass filtering. Please see [Merged Bam Format](data_formats/alignment.md#merged-bam)                    |
| all_cells_bulk_contaminated.bam.bai        | bam index                                                                                                                                     |
| all_cells_bulk_control.bam                 | merged bam with all control cells. Please see [Merged Bam Format](data_formats/alignment.md#merged-bam)                                       |
| all_cells_bulk_control.bam.bai             | bam index                                                                                                                                     |
| detailed_fastqscreen_breakdown.csv.gz      | per cell contamination breakdown in csv format. Please see [FastqScreen Breakdown Csv](data_formats/alignment.md#detailed-fastqscreen-metrics)|
| detailed_fastqscreen_breakdown.csv.gz.yaml | metadata for contamination metrics csv. Please refer to [csverve](https://csverve.readthedocs.io/en/latest/)                                  |
| metadata.yaml                              | Please see [Metadata Output](data_formats/metadata_yaml_output.md#alignment)                                                                  |
| hmmcopy_heatmap.pdf          | Heatmap pdf with clustering                                                                                                                       | 
| hmmcopy_metrics.csv.gz       | metrics collected from hmmcopy and other postprocessing tools. Please see [hmmcopy_metrics](data_formats/hmmcopy.md#hmmcopy-metrics) for details. | 
| hmmcopy_metrics.csv.gz.yaml  | csv yaml file                                                                                                                                     |                                                                                                                        
| hmmcopy_params.csv.gz        | param metrics collected from hmmcopy. Please see [hmmcopy_params](data_formats/hmmcopy.md#hmmcopy-params) for details.                            | 
| hmmcopy_params.csv.gz.yaml   | csv yaml file                                                                                                                                     | 
| hmmcopy_reads.csv.gz         | reads data collected from hmmcopy. Please see [hmmcopy_reads](data_formats/hmmcopy.md#hmmcopy-reads) for details.                                 | 
| hmmcopy_reads.csv.gz.yaml    | csv yaml file                                                                                                                                     | 
| hmmcopy_segments.csv.gz      | segments data collected from hmmcopy. Please see [hmmcopy_segments](data_formats/hmmcopy.md#hmmcopy-segments) for details.                        | 
| hmmcopy_segments.csv.gz.yaml | csv yaml file                                                                                                                                     | 
| hmmcopy_segments_fail.tar.gz | Hmmcopy segment plots of all failed cells grouped together into a tarball                                                                         | 
| hmmcopy_segments_pass.tar.gz | Hmmcopy segment plots of all failed cells grouped together into a tarball                                                                         | 
| metadata.yaml                | Please see [Metadata Output](data_formats/metadata_yaml_output.md#hmmcopy)                                                                        | 
| qc_html_report.html          | html formatted report page with quick QC metrics and plots                                                                                        | 