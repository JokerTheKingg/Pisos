#!/bin/bash

echo "» Restarting dbus"
eval "$(dbus-launch)"
export DISPLAY=:0

echo "» Fixing .xinitrc"
cat > ~/.xinitrc <<EOF
sxhkd &
exec bspwm
EOF

echo "» Checking if xterm is installed"
if ! command -v xterm &> /dev/null; then
    echo "» Installing xterm"
    sudo pacman -S xterm --noconfirm
fi

echo "» All set. Run 'startx'"
