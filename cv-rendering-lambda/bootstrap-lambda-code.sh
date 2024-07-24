#!/bin/bash

# Expects:
# - source_code_dir
# - target
# - lambda_code_file
# Unfortunately HPC Terraform does not support running Python, thus we need
# to prepare the zip locally

set -eux

rm -rf $target
zip $target $lambda_code_file
