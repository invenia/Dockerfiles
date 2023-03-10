#!/bin/bash

# See the history of this file here
# https://gitlab.invenia.ca/invenia/eis/blob/9cbf147eeec2c75d425ca867ae8e02067af1216e/Dockerfile
set -e

# Override artifacts in JLL packages
julia $JULIA_PATH/set_preferences.jl

# Perform precompilation of packages
julia -e 'using Pkg; VERSION >= v"1.7.0-DEV.521" ? Pkg.precompile(strict=true) : Pkg.API.precompile()'

$(dirname $0)/clean_all.sh
