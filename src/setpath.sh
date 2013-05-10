#!/usr/bin/env bash

# Simple wrapper script to set the path
# If a parameter is provided, it assumes it's something to be sourced before
# (such as a virtualenv activate script)

MY_CWD=`pwd`

if [[ "$1" ]]; then
    source $1
fi

export PYTHONPATH=$PYTHONPATH:${MY_CWD}

