#!/usr/bin/env bash

# set -e : exit the script if any statement returns a non-true return value
set -o errexit

command=$(/opt/nfsen/bin/nfsen status | grep -c "is not running")

if [[ $command  == "0" ]]; then
    echo "NFSen healthcheck success"
    exit 0
else
    echo "NFSen healthcheck failed"
    exit 2
fi
