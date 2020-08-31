#!/bin/bash
set -e
source /qserv/stack/loadLSST.bash
setup -t qserv-dev qserv_distrib
WORKER=$(hostname -s)
DATABASE=gaia_dr2_02
INPUT=/datasets/gapon/${DATABASE}/qserv-ncsa-gaia/gaia_source
OUTPUT=/qserv/work/${DATABASE}
cd ${OUTPUT}
for f in $(ls ${INPUT}/worker_input/${WORKER}); do \
    STREAM=${f:0:-4}; \
    /qserv/bin/qserv-replica-file-ingest FILE-LIST allocate_chunks/${STREAM}.json --auth-key=CHANGEME --verbose >& logs/ingest.${STREAM}.log& \
done
wait
