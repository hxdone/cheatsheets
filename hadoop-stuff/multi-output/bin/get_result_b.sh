#!/bin/bash

export LC_ALL=C
set -o pipefail
set -o nounset
set -o errexit

awk -F"\t" '{print $1"	"$2}' # multi-column-output
