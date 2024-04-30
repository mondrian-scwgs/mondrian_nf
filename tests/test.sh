#!/bin/bash

TEST_DIR=$1
RESOURCE_DIR=$2
PIPELINE=$3
DOCKER=$4
TEST_DATA=$5

TEMP_DIR=$TEST_DIR/$PIPELINE

mkdir -p $TEMP_DIR && cd $TEMP_DIR

mkdir data
wget -nv https://mondriantestdata.s3.amazonaws.com/${TEST_DATA}_testdata.tar.gz
tar -xvf ${TEST_DATA}_testdata.tar.gz -C data

DATA_DIR=`ls -d $PWD/data/*`

TAG=`git describe --tags $(git rev-list --tags --max-count=1)`
sed -i 's@mondrian-ref-path-here@'"$RESOURCE_DIR"'/mondrian-ref-20-22@g' ${TEST_DIR}/${PIPELINE}.yaml
sed -i 's@mondrian-data-path-here@'"$DATA_DIR"'/@g' ${TEST_DIR}/${PIPELINE}.yaml
sed -i 's@mondrian-data-path-here@'"$DATA_DIR"'/@g' ${TEST_DIR}/samplesheet.csv

cp ${TEST_DIR}/samplesheet.csv .
cp ${TEST_DIR}/nextflow.config .


cat ${TEST_DIR}/${PIPELINE}.yaml

ls -l ${DATA_DIR}/normal.bam
ls -l ${RESOURCE_DIR}/mondrian-ref-20-22/human/GRCh37-lite.fa


echo "" >> nextflow.config
echo "providers.github.user = "$GHUB_USERNAME >> nextflow.config
echo "providers.github.token = "$GHUB_PASSWORD >> nextflow.config

$RESOURCE_DIR/nextflow pull mondrian-scwgs/mondrian_nf -r $TAG
$RESOURCE_DIR/nextflow run mondrian-scwgs/mondrian_nf -r $TAG -params-file ${TEST_DIR}/${PIPELINE}.yaml -resume --max_cpus 2  -profile docker

