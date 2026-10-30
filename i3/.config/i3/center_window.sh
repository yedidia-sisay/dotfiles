#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <width> <height>"
    exit 1
fi

WIDTH=$1
HEIGHT=$2

i3-msg "resize set $WIDTH $HEIGHT, move position center"
