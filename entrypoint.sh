#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

[[ "$DEBUG" == "true" ]] && set -x

# Starting nfsend
/opt/nfsen/bin/nfsen start

mkdir -p /run/lighttpd
[[ $(stat -c %U /run/lighttpd) == "www-data" ]] || chown -R www-data /run/lighttpd
[[ $(stat -c %G /run/lighttpd) == "www-data" ]] || chgrp -R www-data /run/lighttpd

[[ $(stat -c %U /var/www/nfsen) == "www-data" ]] || chown -R www-data /var/www/nfsen
[[ $(stat -c %G /var/www/nfsen) == "www-data" ]] || chgrp -R www-data /var/www/nfsen

exec "$@"
