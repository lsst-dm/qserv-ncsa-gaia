#!/bin/bash
set -e
source /qserv/stack/loadLSST.bash
setup -t qserv-dev qserv_distrib
DATABASE=gaia_dr2_02
INPUT=/datasets/gapon/${DATABASE}/regular
OUTPUT=/qserv/work/${DATABASE}

mkdir -p ${OUTPUT}
cd ${OUTPUT}
mkdir -p logs regular

# Register tables
for TABLE in $(cat ${INPUT}/tables); do \
    curl 'http://localhost:25080/ingest/table' -X POST -H "Content-Type: application/json" -d@${INPUT}/${TABLE}/${TABLE}.json -o logs/register.${TABLE}.result >& logs/register.${TABLE}.log; \
done

# Start a transaction
curl 'http://localhost:25080/ingest/trans' -X POST -H "Content-Type: application/json" -d'{"database":"'${DATABASE}'","auth_key":"kukara4a"}' -o logs/transaction_begin.result >& logs/transaction_begin.log
cat logs/transaction_begin.result | grep -zoP '"id":[0-9]+' | awk -F: '{print $2}' > regular/transaction_id
TRANSACTION_ID=$(cat regular/transaction_id)

# Generate config files for the batch loading, one file per table
curl 'http://localhost:25080/ingest/regular/'${TRANSACTION_ID} -X GET -H "Content-Type: application/json" -d'{"database":"'${DATABASE}'"}' -o logs/location.result >& logs/location.log
cat logs/location.result  | tr '{},[]' ' ' | grep -zoP '("host":("[^ ]+"))|("port":[0-9]+)' | grep port | awk -F: '{print $2}' | sort -u > regular/port
cat logs/location.result  | tr '{},[]' ' ' | grep -zoP '("host":("[^ ]+"))|("port":[0-9]+)' | grep host | awk -F\" '{print $4}' > regular/workers
PORT=$(cat regular/port)
for TABLE in $(cat ${INPUT}/tables); do \
    CONFIG="regular/${TABLE}.json"; \
    echo -n '[' > ${CONFIG}; \
    unset NOT_EMPTY; \
    for FILE in $(ls ${INPUT}/${TABLE}/input/*.csv); do \
        COMMA=
        for WORKER in $(cat regular/workers); do \
            if [ ! -z "${NOT_EMPTY}" ]; then \
                echo -n ',' >> ${CONFIG}; \
            fi; \
            NOT_EMPTY=1; \
            echo -n '{"worker-host":"'$WORKER'","worker-port":'$PORT',"path":"'$FILE'"}' >> ${CONFIG}; \
        done; \
    done; \
    echo -n ']' >> ${CONFIG}; \
done

# Ingest tables in parallel
for TABLE in $(cat ${INPUT}/tables); do \
    CONFIG="regular/${TABLE}.json"; \
    /qserv/bin/qserv-replica-file-ingest FILE-LIST-TRANS ${TRANSACTION_ID} ${TABLE} R ${CONFIG} --auth-key=kukara4a --verbose >& logs/ingest.${TABLE}.log& \
done
wait

# Commit the transaction
curl 'http://localhost:25080/ingest/trans/'${TRANSACTION_ID}'?abort=0' -X PUT -H "Content-Type: application/json" -d'{"auth_key":"kukara4a"}' -o logs/transaction_commit.result >& logs/transaction_commit.log


