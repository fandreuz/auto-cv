#!/bin/bash

# Expects:
# - source_code_dir
# - target_dir
# - python_executable
# Unfortunately HPC Terraform does not support running Python, thus we need
# to prepare the zip locally

set -eux

rm -rf $target

venv_path=$source_code_dir/venv_tmp
rm -rf $venv_path

$python_executable -m venv $venv_path
source $venv_path/bin/activate
python -m pip install -r $source_code_dir/requirements.txt
deactivate

cd $venv_path/lib/python*/site-packages
rm -rf pip setuptools
zip -r ../../../../$target .
cd ../../../..

rm -rf $venv_path
