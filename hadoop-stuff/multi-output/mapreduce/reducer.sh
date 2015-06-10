#!/bin/bash

export LC_ALL=C
set -o pipefail
set -o nounset
set -o errexit

tar -xzf bin.tar.gz
chmod +x bin/*

cat > input.txt

cat input.txt | bin/get_result_a.sh > result_a.txt
cat input.txt | bin/get_redult_b.sh > result_b.txt

# do multi-output
cat result_a.txt | while read line; do echo "${line}	#A"; done # for one-column output
cat result_b.txt | while read line; do echo "${line}#B"; done # for multi-column output 
