#!/bin/bash
set -e
source /qserv/stack/loadLSST.bash
setup -t qserv-dev qserv_distrib
WORKER=$(hostname -s)
DATABASE=gaia_dr2_02
INPUT=/datasets/gapon/${DATABASE}/qserv-ncsa-gaia/gaia_source
OUTPUT=/qserv/work/${DATABASE}
cd ${OUTPUT}
mkdir -p transactions
rm transactions/*
for f in $(ls ${INPUT}/worker_input/${WORKER}); do \
    STREAM=${f:0:-4}; \
    python ${INPUT}/worker_scripts/transaction_begin.py > transactions/${STREAM} 2>logs/transaction_begin.${STREAM}.log; \
done
