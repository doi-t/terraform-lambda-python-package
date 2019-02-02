#!/bin/bash
set -e

PACKAGE_NAME=$1
PYTHON_VERSION=$2 # '3.6', '3.7', etc...
SOURCE_DIR=$3
PACKAGE_DIR=$4
BUILD_DIR=$5

mkdir -p ${BUILD_DIR} # temporary directory for venv
mkdir -p ${PACKAGE_DIR} # source directory that will be zipped up by terraform

# source files
cp -r ./${SOURCE_DIR}/* ./${PACKAGE_DIR}

# pip packages
if [ -e ./${SOURCE_DIR}/requirements.txt ]; then
    python${PYTHON_VERSION} -m venv ${BUILD_DIR}/${PACKAGE_NAME}
    . ${BUILD_DIR}/${PACKAGE_NAME}/bin/activate
    pip3 install  -r ./${SOURCE_DIR}/requirements.txt  -t ./${PACKAGE_DIR}
fi
