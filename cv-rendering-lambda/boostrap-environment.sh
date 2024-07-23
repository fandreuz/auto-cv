#!/bin/bash

# Expects:
# - source_code_dir
# - source_code_filename
# - target_dir

temp_dir=$(mktemp -d)
venv_name=venv
# We're gonna cd soon
target_dir=$(realpath $target_dir)
source_code_dir=$(realpath $source_code_dir)

clean_up () {
    ARG=$?
    rm -rf $temp_dir
    exit $ARG
}
trap clean_up EXIT

cd $temp_dir
python -m venv $venv_name
source $venv_name/bin/activate
python -m pip install $source_code_dir

rm -rf $target_dir
mkdir $target_dir
cp -r $venv_name/lib/*/site-packages/* $target_dir
