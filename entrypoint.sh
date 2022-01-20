#!/usr/bin/env bash

echo "Starting nfsen ..."
/opt/nfsen/bin/nfsen start

echo "Starting lighttpd ..."
/etc/init.d/lighttpd start

echo "Blocking TTY ..."
sleep infinity
