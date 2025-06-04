#!/bin/bash

echo ">>> Checking NVIDIA socket permissions in /var/run/"

SOCKETS=$(ls /var/run/nvidia-xdriver-* 2>/dev/null)
if [ -z "$SOCKETS" ]; then
  echo "No NVIDIA sockets found in /var/run/. Is the driver loaded?"
else
  for socket in $SOCKETS; do
    echo "Socket: $socket"
    ls -l "$socket"
    echo "Setting permissions to 666 (read/write for all)..."
    sudo chmod 666 "$socket"
  done
fi

echo
echo ">>> Checking nvidia-persistenced service status..."

if systemctl is-active --quiet nvidia-persistenced; then
  echo "nvidia-persistenced is running."
else
  echo "nvidia-persistenced is NOT running. Starting and enabling it now..."
  sudo systemctl start nvidia-persistenced
  sudo systemctl enable nvidia-persistenced
fi

echo
echo ">>> Done. Please reboot your system and try 'startx' again."
