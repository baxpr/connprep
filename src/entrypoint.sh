#!/usr/bin/env bash

xvfb-run --server-num=$(($$ + 99)) \
    --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
    run_spm12.sh ${MATLAB_RUNTIME} function connprep "$@"
