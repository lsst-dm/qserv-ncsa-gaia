#!/bin/bash
set -e
. /datasets/gapon/gaia_dr2_02/qserv-ncsa-gaia/gaia_source/scripts/env.sh
$CONTAINER_CMD /datasets/gapon/gaia_dr2_02/qserv-ncsa-gaia/gaia_source/worker_scripts/transaction_begin.sh >& /tmp/transaction_begin.log
