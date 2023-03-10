#!/bin/bash

# See the history of this file here
# https://gitlab.invenia.ca/invenia/eis/blob/9cbf147eeec2c75d425ca867ae8e02067af1216e/Dockerfile
set -e

# Install and build the package requirements. Record any system packages that need to be
# installed in order to build any dependencies which is helpful for future maintenence.
#
# - PyCall: tar, bzip2
# - Conda: Requires the `conda clean` call to avoid bloating the Docker image size
PKGS="tar bzip2"
yum -y -d1 install $PKGS

# Run `Pkg.instantiate` in the environment directory where we saved our Manifest.toml
# and Project.toml files.
env JULIA_PKG_PRECOMPILE_AUTO=0 julia -e "using Pkg; Pkg.Registry.update(); Pkg.instantiate()"

$(dirname $0)/clean_all.sh $PKGS
