#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

EMACS_VERSION="$(echo $EMACS_VERSION | cut -f 1 -d '.')"

if [ -eq "$EMACS_VERSION" 27 ];then
    cp Cask-27 Cask
else
    cp Cask-default Cask
fi
