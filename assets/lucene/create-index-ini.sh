#!/usr/bin/env bash

set -e

envsubst < /lucene/index.ini.template > /lucene/index.ini

