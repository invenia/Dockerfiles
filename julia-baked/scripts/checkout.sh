#!/bin/bash

# See the history of this file here
# https://gitlab.invenia.ca/invenia/eis/blob/9cbf147eeec2c75d425ca867ae8e02067af1216e/Dockerfile
set -e

BRANCH=$@

PKGS="tar bzip2"
yum -y -d1 install $PKGS
julia $JULIA_PATH/checkout.jl $BRANCH

$(dirname $0)/clean_all.sh $PKGS
