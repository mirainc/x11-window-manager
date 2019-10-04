#!/usr/bin/bash

if [[ -z "$DISPLAY" ]]; then
    export DISPLAY=:0
fi

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# rotate screen if env variable is set [normal, inverted, left or right]
if [[ ! -z "$ROTATE_DISPLAY" ]]; then
  echo "YES"
  (sleep 3 && DISPLAY=:0 xrandr -o $ROTATE_DISPLAY) &
fi

# start desktop manager

if [[ "$DISPLAY" == "host.docker.internal:0" && "$UDEV" -eq 0 ]]; then
    # allow X-windows apps access for *any* user on the system
    xhost +SI:localuser:chrome
    xterm &
    bash ./chrome.sh
else
    echo "STARTING X"
    source ./setup_lte.sh &
    startx
fi
