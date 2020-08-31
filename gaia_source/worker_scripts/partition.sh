#!/bin/bash
set -e
source /qserv/stack/loadLSST.bash
setup -t qserv-dev qserv_distrib
WORKER=$(hostname -s)
DATABASE=gaia_dr2_02
INPUT=/datasets/gapon/${DATABASE}/qserv-ncsa-gaia/gaia_source
OUTPUT=/qserv/work/${DATABASE}
mkdir -p ${OUTPUT}
cd ${OUTPUT}
rm -rf ./*
mkdir chunks
mkdir logs
for f in $(ls ${INPUT}/worker_input/${WORKER}); do \
    STREAM=${f:0:-4}; \
    sph-partition --out.dir=chunks/${STREAM} \
        --in=${INPUT}/worker_input/${WORKER}/${f} \
        --config-file=${INPUT}/partition.cfg \
        >& logs/partition.${STREAM}.log; \
done
