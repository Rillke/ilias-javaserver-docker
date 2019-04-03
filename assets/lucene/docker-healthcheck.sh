#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ILIAS_JAVA_SERVER_HEARTBEAT_URL="http://127.0.0.1:11111//RPC2"
PAYLOAD='<?xml version="1.0" encoding="UTF-8"?><methodCall><methodName>RPCAdministration.status</methodName><params></params></methodCall>'

# Send request to RPCAdministration.status endpoint
# expected response: <?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value>Runnning</value></param></params></methodResponse>
HTTP_CODE=$(curl \
  -H 'Host: 0.0.0.0:11111' \
  -H "Content-Length: ${#PAYLOAD}" \
  -d "${PAYLOAD}" \
  -sw '%{http_code}' \
  -o /dev/null \
  --max-time 5 \
  "${ILIAS_JAVA_SERVER_HEARTBEAT_URL}" \
)
[                -n "$?" ] || exit 1
[ "${HTTP_CODE}" -ge 200 ] && \
[ "${HTTP_CODE}" -lt 300 ] || exit 1

HTTP_CONTENT=$(curl \
  -H 'Host: 0.0.0.0:11111' \
  -H "Content-Length: ${#PAYLOAD}" \
  -d "${PAYLOAD}" \
  -s \
  --max-time 5 \
  "${ILIAS_JAVA_SERVER_HEARTBEAT_URL}" \
)

if [[ ${HTTP_CONTENT} != *"Runnning"* ]] && [[ ${HTTP_CONTENT} != *"Indexing"* ]]; then
  exit 1
fi

