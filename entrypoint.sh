#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

# Starting nfsend
/opt/nfsen/bin/nfsen start

mkfifo -m 600 /tmp/logpipe
cat <> /tmp/logpipe 1>&2 &
chown www-data /tmp/logpipe

mkdir -p /run/lighttpd
chown www-data /run/lighttpd

exec "$@"
