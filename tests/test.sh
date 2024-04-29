#!/bin/bash

TEST_DIR=$1
RESOURCE_DIR=$2
PIPELINE=$3
DOCKER=$4
TEST_DATA=$5

TEMP_DIR=$TEST_DIR/$PIPELINE

mkdir -p $TEMP_DIR && cd $TEMP_DIR

wget -nv https://mondriantestdata.s3.amazonaws.com/${TEST_DATA}_testdata.tar.gz
tar -xvf ${TEST_DATA}_testdata.tar.gz



TAG=`git describe --tags $(git rev-list --tags --max-count=1)`
sed -i 's@docker_image_here@quay.io/mondrianscwgs/'"$DOCKER"':'"$TAG"beta'@g' ${TEST_DIR}/${PIPELINE}.json
sed -i 's@mondrian-ref-path-here@'"$RESOURCE_DIR"'/mondrian-ref-20-22@g' ${TEST_DIR}/${PIPELINE}.json


echo "$$$$$$$$$$$$$$$$$$$$$$$$$$"
cat ${TEST_DIR}/${PIPELINE}.json
echo "$$$$$$$$$$$$$$$$$$$$$$$$$$"

java -Dconfig.file=run.config -jar $RESOURCE_DIR/cromwell.jar run ${CODEBUILD_SRC_DIR}/mondrian/${PIPELINE}.wdl -i ${TEST_DIR}/${PIPELINE}.json -o options.json --imports $RESOURCE_DIR/imports_${TAG}.zip


