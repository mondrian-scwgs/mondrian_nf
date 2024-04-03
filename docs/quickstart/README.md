# Mondrian Quickstart Guide


### Download the reference data

  we'll start with this smaller reference dataset for our quickstart guide. 
  ```
  wget https://mondriantestdata.s3.amazonaws.com/mondrian-ref-20-22.tar.gz
  tar -xvf mondrian-ref-20-22.tar.gz
  ```
  
  full GRCh37 reference data is available at
  ```
  https://mondriantestdata.s3.amazonaws.com/mondrian-ref-GRCh37.tar.gz
  ```
  full GRCh38 reference data is available at
  ```
  https://mondriantestdata.s3.amazonaws.com/mondrian-ref-GRCh38.tar.gz
  ```

### Download and install nextflow

  ```
  wget -qO- https://get.nextflow.io | bash
  ```

### Analyses:

To continue quickstart, please choose the analysis you'd like to run:

- [QC](quickstart/qc.md)
- [variant](quickstart/variant.md)
- [breakpoint](quickstart/breakpoint.md)
- [snv genotyping](quickstart/snv_genotyping.md)
- [normalizer](quickstart/normalizer.md)
- [haplotype counts](quickstart/counthaps.md)
- [haplotype infer](quickstart/inferhaps.md)
