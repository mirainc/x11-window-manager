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

if [[ -z "MODE" ]]; then
    MODE="1920x1080"
fi
if [[ -z "OUTPUT" ]]; then
    OUTPUT="HDMI2"
fi
xrandr --output $OUTPUT --mode $MODE

# xterm &
xterm -geometry 80x40-0+0 -fg black -bg white -fn 10x20 &
# launch chrome
runuser -l chrome -c "DISPLAY=$DISPLAY /usr/bin/google-chrome --no-first-run --window-size=1280,1080"
