#!/bin/bash

# Expects:
# - source_code_dir
# - target_dir
# - python_executable

set -eux

rm -rf $target_dir
mkdir $target_dir
$python_executable -m pip install $source_code_dir --target $target_dir
