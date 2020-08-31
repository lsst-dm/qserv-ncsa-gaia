#!/bin/bash
set -e
source /qserv/stack/loadLSST.bash
setup -t qserv-dev qserv_distrib
WORKER=$(hostname -s)
DATABASE=gaia_dr2_02
INPUT=/datasets/gapon/${DATABASE}/qserv-ncsa-gaia/gaia_source
OUTPUT=/qserv/work/${DATABASE}
cd ${OUTPUT}
mkdir -p allocate_chunks
rm -f allocate_chunks/*
for f in $(ls ${INPUT}/worker_input/${WORKER}); do \
    STREAM=${f:0:-4}; \
    python ${INPUT}/worker_scripts/allocate_chunks.py $(cat transactions/${STREAM}) chunks/${STREAM} > allocate_chunks/${STREAM}.json 2>logs/allocate_chunks.${STREAM}.log; \
done
