#!/usr/bin/env bash

set -e

envsubst < /lucene/index.ini.template > /lucene/index.ini
envsubst < /lucene/ilServer.properties.template > /var/www/ilias/Services/WebServices/RPC/lib/ilServer.properties

