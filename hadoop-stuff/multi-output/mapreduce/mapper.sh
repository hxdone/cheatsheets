#!/bin/bash

export LC_ALL=C
set -o pipefail
set -o nounset
set -o errexit

tar -xzf bin.tar.gz
chmod +x bin/*

cat | bin/treat_map_input.sh
