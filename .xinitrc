#!/usr/bin/bash

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# rotate screen if env variable is set [normal, inverted, left or right]
if [[ ! -z "$ROTATE_DISPLAY" ]]; then
  echo "YES"
  (sleep 3 && DISPLAY=:0 xrandr -o $ROTATE_DISPLAY) &
fi

# start desktop manager
echo "STARTING X"

# allow X-windows apps access for *any* user on the system
xhost +SI:localuser:chrome

# xterm &
xterm -geometry 960x1080-0+0 -fg black -bg white &
# launch chrome
runuser -l chrome -c "DISPLAY=$DISPLAY /usr/bin/google-chrome --no-first-run --window-size=960,1080"
