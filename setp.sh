#!/bin/bash

echo "» Checking NVIDIA driver"
if ! nvidia-smi &> /dev/null; then
  echo "» Error: NVIDIA driver is not loaded or not installed"
else
  echo "» OK: NVIDIA driver is working"
fi

echo "» Checking if bspwm is installed"
if ! command -v bspwm &> /dev/null; then
  echo "» Error: bspwm is not installed"
else
  echo "» OK: bspwm is installed"
fi

echo "» Checking if sxhkd is installed"
if ! command -v sxhkd &> /dev/null; then
  echo "» Error: sxhkd is not installed"
else
  echo "» OK: sxhkd is installed"
fi

echo "» Checking .xinitrc file"
if [ ! -f ~/.xinitrc ]; then
  echo "» Error: .xinitrc file not found"
else
  grep "exec bspwm" ~/.xinitrc &> /dev/null
  if [ $? -eq 0 ]; then
    echo "» OK: .xinitrc contains 'exec bspwm'"
  else
    echo "» Warning: .xinitrc does not contain 'exec bspwm'"
  fi
fi

echo "» Checking Xorg log for errors"
XLOG=$(find ~/.local/share/xorg /var/log -name "Xorg.0.log" 2>/dev/null | head -n 1)
if [ -f "$XLOG" ]; then
  echo "» Found Xorg log at $XLOG"
  grep -E "(EE|WW)" "$XLOG" | grep -v "EE) Failed to load module \"fbdev\"" | grep -v "EE) Failed to load module \"vesa\""
else
  echo "» Error: Xorg log not found"
fi

echo "» Checking DBus status"
if ! pidof dbus-daemon > /dev/null; then
  echo "» Warning: dbus-daemon is not running"
else
  echo "» OK: dbus-daemon is running"
fi

echo "» Checking DISPLAY"
if [ -z "$DISPLAY" ]; then
  echo "» Warning: DISPLAY is not set"
else
  echo "» OK: DISPLAY=$DISPLAY"
fi
