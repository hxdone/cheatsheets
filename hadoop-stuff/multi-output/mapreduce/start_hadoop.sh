#!/bin/bash

export LC_ALL=C
set -o pipefail
set -o nounset
set -o errexit

WORK_DIR=`dirname $0`
cd ${WORK_DIR}

rm -f bin.tar.gz
tar -cvzf bin.tar.gz ../bin/*

HADOOP="your-absolute-hadoop-client-path/bin/hadoop"
#PYTHON_ARCHIVE="somewhere_on_hdfs/python2.7.tar.gz#python27"

INPUT_DIR="your-input-dir"
OUTPUT_DIR="your-output-dir"
REAL_OUTPUT_DIR_1="somewhere_1"
REAL_OUTPUT_DIR_2="somewhere_2"

set +e # OUTPUT_DIR may not exist
${HADOOP} fs -rmr "${OUTPUT_DIR}"
${HADOOP} fs -rmr "${REAL_OUTPUT_DIR_1}"
${HADOOP} fs -rmr "${REAL_OUTPUT_DIR_2}"
set -e

${HADOOP} streaming \
-D mapred.job.name="your-job-name" \
-D mapred.job.priority="NORMAL" \
-D mapred.reduce.tasks="20000" \
-input "${INPUT_DIR}" \
-output "${OUTPUT_DIR}" \
-mapper "sh mapper.sh" \
-reducer "sh reducer.sh" \
-outputformat org.apache.hadoop.mapred.lib.SuffixMultipleTextOutputFormat \
-file "bin.tar.gz" \
-file "mapper.sh" \
-file "reducer.sh"
#-cacheArchive "${PYTHON_ARCHIVE}" \

${HADOOP} fs -mkdir "${REAL_OUTPUT_DIR_1}"
${HADOOP} fs -mkdir "${REAL_OUTPUT_DIR_2}"

${HADOOP} fs -mv "${OUTPUT_DIR}/part-*-A" "${REAL_OUTPUT_DIR_1}" 
${HADOOP} fs -mv "${OUTPUT_DIR}/part-*-B" "${REAL_OUTPUT_DIR_2}" 

rm -f bin.tar.gz
