#!/usr/bin/bash

if [[ -z "$DISPLAY" ]]; then
    export DISPLAY=:0.0
fi

if [[ "$DISPLAY" == "host.docker.internal:0" && "$UDEV" -eq 0 ]]; then
    bash /usr/src/app/.xinitrc
else
    startx /usr/src/app/.xinitrc
fi
