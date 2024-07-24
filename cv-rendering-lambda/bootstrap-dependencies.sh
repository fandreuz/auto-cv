#!/bin/bash

# Expects:
# - requirements_file
# - target
# - python_executable
# Unfortunately HPC Terraform does not support running Python, thus we need
# to prepare the zip locally

set -eux

rm -rf $target

venv_path=venv_tmp
rm -rf $venv_path

$python_executable -m venv $venv_path
source $venv_path/bin/activate
python -m pip install -r $requirements_file
deactivate

cd $venv_path/lib/python*/site-packages
rm -rf pip setuptools
find . -type d -name '__pycache__' -exec rm -rf {} +
find . -type d -name '*.dist-info' -exec rm -rf {} +
zip -r ../../../../$target .
cd ../../../..

rm -rf $venv_path
