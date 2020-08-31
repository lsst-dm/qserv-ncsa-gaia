import requests
import sys
if len(sys.argv) != 2:
    print("usage: <transaction-id>", file=sys.stderr)
    sys.exit(1)
transactionId = int(sys.argv[1])
url='http://lsst-qserv-master03:25081/ingest/trans/{}?abort=0'.format(transactionId)
response = requests.put(url, json={"auth_key":"CHANGEME"})
response.raise_for_status()
responseJson = response.json()
if not responseJson['success']:
    print("error: " + responseJson['error'], file=sys.stderr)
    sys.exit(1)
