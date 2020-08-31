import glob
import os
import requests
import json as json
import sys

if len(sys.argv) != 3:
    print("usage: <transaction-id> <chunks-dir>")
    sys.exit(1)
transactionId = int(sys.argv[1])
chunksDir = sys.argv[2]

chunkLen = len("chunk_")
overlapLen = len("_overlap")
file2chunk = {}
uniqueChunks = {}
for f in glob.glob("{}/chunk_*.txt".format(chunksDir)):
    name = os.path.splitext(os.path.basename(f))[0]
    name = name[chunkLen:]
    if name[-overlapLen:] == "_overlap": name = name[:-overlapLen]
    chunk = int(name)
    file2chunk[f] = chunk
    uniqueChunks[chunk] = chunk
chunks = []
for chunk in uniqueChunks.keys():
    chunks.append(chunk)

url='http://lsst-qserv-master03:25081/ingest/chunks'

response = requests.post(url, json={"transaction_id":transactionId,"chunks":chunks,"auth_key":"CHANGEME"})
response.raise_for_status()
responseJson = response.json()
if not responseJson['success']:
    print("error: " + responseJson['error'], file=sys.stderr)
    sys.exit(1)

chunk2service = {}
for info in responseJson['location']:
    chunk2service[info['chunk']] = {"worker-host":info['host'], "worker-port":info['port']}

loadPlan = []
for file,chunk in file2chunk.items():
    service = chunk2service[chunk]
    loadPlan.append({
        "worker-host":service["worker-host"],
        "worker-port":service["worker-port"],
        "transaction-id":transactionId,
        "table":"gaia_source",
        "type":"P",
        "path":file})
print(json.dumps(loadPlan))
