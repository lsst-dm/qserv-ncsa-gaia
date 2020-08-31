import requests
import sys
url='http://lsst-qserv-master03:25081/ingest/trans'
database='gaia_dr2_02'
response = requests.post(url, json={"database":database, "auth_key":"CHANGEME"})
response.raise_for_status()
responseJson = response.json()
if not responseJson['success']:
    print("error: " + responseJson['error'], file=sys.stderr)
    sys.exit(1)
print(responseJson['databases'][database]['transactions'][0]['id'])
