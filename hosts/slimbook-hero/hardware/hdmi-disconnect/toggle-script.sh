#!/bin/bash

# Set this to your internal display name and external monitor name
INTERNAL="eDP-1"
EXTERNAL="HDMI-1"

# Check power state
DDC_OUTPUT=$(ddcutil --bus=14 getvcp D6 2>/dev/null)
POWER_HEX=$(echo "$DDC_OUTPUT" | grep -oP 'sl=0x\K[0-9a-fA-F]+')
POWER_DEC=$((16#$POWER_HEX))

STATE=$POWER_DEC #$(ddcutil getvcp D6 2>/dev/null | grep -oP '(?<=current value = )\d+')

if [ "$STATE" == "1" ]; then
    # Monitor is ON: Extend display
    xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --above "$INTERNAL"
else
    # Monitor is OFF: Use laptop screen only
    xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --off
fi

