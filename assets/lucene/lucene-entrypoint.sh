#!/usr/bin/env bash

set -e

cd /var/www/ilias

echo 'Substituting variables in ILIAS main configuration'
envsubst '${TZ} ${ILIAS_HTTP_PATH}' \
	< /lucene/ilias.ini.php.template > ilias.ini.php

echo 'Creating lucene index configuration'
source /lucene/create-index-ini.sh

cd -

echo "Starting lucene server ...: $@"
exec "$@"

