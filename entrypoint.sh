#!/usr/bin/env bash

# start nfsen
/opt/nfsen/bin/nfsen start

# start lighttpd
/etc/init.d/lighttpd start

# block
sleep infinity
