#!/bin/bash

export LC_ALL=C
set -o pipefail
set -o nounset
set -o errexit

awk -F"\t" '{if(NF > 1) print $0;}'
