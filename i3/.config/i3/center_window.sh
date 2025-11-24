#!/bin/bash

# Check if width and height are provided as arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <width> <height>"
    exit 1
fi

WIDTH=$1
HEIGHT=$2

# Get screen dimensions using xrandr
SCREEN_INFO=$(xrandr --current | grep '*' | uniq | awk '{print $1}')
SCREEN_WIDTH=$(echo $SCREEN_INFO | cut -d 'x' -f1)
SCREEN_HEIGHT=$(echo $SCREEN_INFO | cut -d 'x' -f2)

# Get the ID of the focused window
FOCUSED_WINDOW=$(i3-msg -t get_tree | jq '.. | objects | select(.focused==true).id')

i3-msg -t get_tree | jq '.. | objects | select(.focused==true)'

# Calculate position to center the window
POS_X=$(( (SCREEN_WIDTH - WIDTH) / 2 ))
POS_Y=$(( (SCREEN_HEIGHT - HEIGHT) / 2 ))

# Use i3-msg to move and resize the focused window
i3-msg "[con_id=$FOCUSED_WINDOW] resize set $WIDTH $HEIGHT, move position $POS_X $POS_Y"

