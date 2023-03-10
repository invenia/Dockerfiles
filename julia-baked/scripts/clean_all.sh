#!/bin/bash
set -e

PKGS=$@

julia "$JULIA_PATH/clean_conda.jl"
for p in $PKGS; do yum -y autoremove $p &>/dev/null && echo "Removed $p" || echo "Skipping removal of $p"; done
yum -y clean all
rm -rf /var/cache/yum
