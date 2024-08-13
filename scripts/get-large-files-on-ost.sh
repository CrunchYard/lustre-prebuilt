#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <size in MB> <OST number>"
    exit 1
fi

export SIZE=$1
export OST=$2

rbh-find "$(pwd -P)" -size +${SIZE}M -exec "./check-ost.sh {} $OST" \; > large-files-on-ost${OST}.csv 2> /dev/null
