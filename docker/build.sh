#!/bin/bash
set -e

TYPE=$1
USERNAME=$2
PASSWORD=$3

VERSION=`git describe --tags $(git rev-list --tags --max-count=1)`

cd $TYPE

docker login quay.io -u $USERNAME --password $PASSWORD

docker build --build-arg VERSION=$VERSION -t quay.io/mondrianscwgs/$TYPE:$VERSION .

docker push quay.io/mondrianscwgs/$TYPE:$VERSION


cd ../
