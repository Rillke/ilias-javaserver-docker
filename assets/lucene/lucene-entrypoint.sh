#!/usr/bin/env bash

set -e


cd /var/www/ilias

echo 'Checking the environment'
export ILIAS_SETUP_PASS_HASH=`echo -n "$ILIAS_SETUP_PASSWORD" | md5sum | cut -d ' ' -f 1`
export ILIAS_CONVERT_PATH=`which convert`
export ILIAS_ZIP_PATH=`which zip`
export ILIAS_UNZIP_PATH=`which unzip`
export ILIAS_JAVA_PATH=`which java`
export ILIAS_FFMPEG_PATH=`which ffmpeg`
export ILIAS_HTMLDOC_PATH=`which htmldoc`
DATE=`date +%Y-%m-%d:%H:%M:%S`

echo 'Substituting variables in ILIAS main configuration'
envsubst '${TZ} ${NGINX_SERVER_NAME} ${NGINX_PROTOCOL}
	${ILIAS_SETUP_PASS_HASH} ${ILIAS_CONVERT_PATH} ${ILIAS_ZIP_PATH}
	${ILIAS_UNZIP_PATH} ${ILIAS_JAVA_PATH} ${ILIAS_FFMPEG_PATH}
	${ILIAS_HTMLDOC_PATH}' \
	< ilias.ini.php.template > ilias.ini.php

echo 'Creating lucene index configuration'
source /lucene/create-index-ini.sh

cd -

echo "Starting lucene server ...: $@"
exec "$@"

echo 'lucene exited'

