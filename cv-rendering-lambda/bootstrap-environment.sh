#!/bin/bash

# Expects:
# - source_code_dir
# - target_dir
# - python_executable
# Unfortunately HPC Terraform does not support running Python, thus we need
# to prepare the zip locally

set -eux

rm -rf $target_dir
rm -rf $target_dir.zip
mkdir $target_dir

$python_executable -m pip install $source_code_dir --target $target_dir
find target -type d -name '*.dist-info' -exec rm -rf {} +
find target -type d -name '__pycache__' -exec rm -rf {} +

zip -r $target_dir.zip $target_dir
rm -rf $target_dir
