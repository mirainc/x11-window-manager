#!/usr/bin/bash

# sleep infinity

if [[ -z "$DISPLAY" ]]; then
    export DISPLAY=:0.0
fi

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# rotate screen if env variable is set [normal, inverted, left or right]
if [[ ! -z "$ROTATE_DISPLAY" ]]; then
  echo "YES"
  (sleep 3 && DISPLAY=:0 xrandr -o $ROTATE_DISPLAY) &
fi

# start desktop manager
echo "STARTING X"
# startx xterm

# allow X-windows apps access for *any* user on the system
xhost +

# # enable X11 forwarding
# ssh chrome@$HOSTNAME -X

# # enable trusted X11 forwarding for this specific user
# ssh chrome@$HOSTNAME -Y

# uncomment to open an application instead of the desktop
# startx xterm

# launch chrome
if [[ "$DISPLAY" == "host.docker.internal:0" && "$UDEV" -eq 0 ]]; then
    runuser -l chrome -c "DISPLAY=$DISPLAY /usr/bin/google-chrome"
else
    startx runuser -l chrome -c "DISPLAY=$DISPLAY /usr/bin/google-chrome"
fi
