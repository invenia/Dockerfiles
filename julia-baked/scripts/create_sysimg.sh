#!/bin/bash

# See the history of this file here
# https://gitlab.invenia.ca/invenia/eis/blob/9cbf147eeec2c75d425ca867ae8e02067af1216e/Dockerfile
set -e

# PRECOMPILE_FILE contains a manually generated list of precompile statements generated via
# `--trace-compile`. For details see:
# https://julialang.github.io/PackageCompiler.jl/dev/sysimages/#Using-a-manually-generated-list-of-precompile-statements-1
PRECOMPILE_FILE=$1

PKGS=gcc
yum -y -d1 install $PKGS
source $JULIA_PATH/Make.user

# MARCH comes from Make.user
julia $JULIA_PATH/compile_packages.jl $MARCH $PRECOMPILE_FILE

$(dirname $0)/clean_all.sh $PKGS
