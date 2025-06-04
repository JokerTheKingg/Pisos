#!/bin/bash

echo ">>> Starting Mega Check & Fix Script for Arch + NVIDIA Optimus Laptop <<<"

# Функція для перевірки пакета
check_pkg() {
  pacman -Qi "$1" &>/dev/null
}

# Функція для встановлення пакета, якщо відсутній
install_pkg() {
  if ! check_pkg "$1"; then
    echo "Package '$1' is missing, installing..."
    sudo pacman -S --noconfirm "$1"
  else
    echo "Package '$1' is already installed."
  fi
}

# 1. Встановлюємо базові пакети
echo -e "\n>>> Checking essential packages..."
ESSENTIAL_PKGS=("nvidia" "nvidia-utils" "nvidia-prime" "bspwm" "sxhkd" "xorg-xinit" "xterm" "dbus")
for pkg in "${ESSENTIAL_PKGS[@]}"; do
  install_pkg "$pkg"
done

# 2. Перевірка NVIDIA драйвера
echo -e "\n>>> Checking NVIDIA driver..."
if lsmod | grep -q nvidia; then
  echo "NVIDIA kernel module is loaded."
else
  echo "NVIDIA kernel module NOT loaded! Try: sudo modprobe nvidia"
fi

# 3. Перевірка сервісу nvidia-persistenced
echo -e "\n>>> Checking nvidia-persistenced service..."
if systemctl is-active --quiet nvidia-persistenced; then
  echo "nvidia-persistenced service is running."
else
  echo "nvidia-persistenced is NOT running, starting and enabling it..."
  sudo systemctl start nvidia-persistenced
  sudo systemctl enable nvidia-persistenced
fi

# 4. Перевірка сокетів NVIDIA
echo -e "\n>>> Checking NVIDIA sockets permissions..."
SOCKETS=$(find /var/run/ -name "nvidia-*")
if [[ -z "$SOCKETS" ]]; then
  echo "No NVIDIA sockets found in /var/run/. Is the driver loaded?"
else
  echo "NVIDIA sockets found:"
  echo "$SOCKETS"
  echo "Checking permissions:"
  ls -l $SOCKETS
fi

# 5. Перевірка PRIME (optimus-manager або prime-select)
echo -e "\n>>> Checking PRIME configuration..."
if command -v optimus-manager &>/dev/null; then
  echo "Optimis-manager is installed."
  echo "Current profile:"
  optimus-manager --print-mode
elif command -v prime-select &>/dev/null; then
  echo "prime-select is installed."
  echo "Current profile:"
  prime-select query
else
  echo "Neither optimus-manager nor prime-select found."
  echo "Consider installing one for PRIME support on hybrid graphics."
fi

# 6. Перевірка DBUS
echo -e "\n>>> Checking DBUS status..."
if systemctl is-active --quiet dbus; then
  echo "DBUS service is running."
else
  echo "DBUS service is NOT running! Starting..."
  sudo systemctl start dbus
  sudo systemctl enable dbus
fi

# 7. Перевірка DISPLAY
echo -e "\n>>> Checking DISPLAY environment variable..."
if [[ -z "$DISPLAY" ]]; then
  echo "DISPLAY is not set. It should be set after X starts."
else
  echo "DISPLAY=$DISPLAY"
fi

# 8. Перевірка .xinitrc
echo -e "\n>>> Checking ~/.xinitrc..."
if [[ -f ~/.xinitrc ]]; then
  if grep -q "exec bspwm" ~/.xinitrc; then
    echo ".xinitrc contains 'exec bspwm' - OK"
  elif grep -q "exec xterm" ~/.xinitrc; then
    echo ".xinitrc contains 'exec xterm' - OK"
  else
    echo "Warning: .xinitrc does not contain 'exec bspwm' or 'exec xterm'"
    echo "Appending 'exec xterm' to .xinitrc"
    echo "exec xterm" >> ~/.xinitrc
  fi
else
  echo ".xinitrc not found. Creating default with 'exec xterm'."
  echo "exec xterm" > ~/.xinitrc
fi

# 9. Лог Xorg - шукаємо помилки (останній лог)
LOGFILE="$HOME/.local/share/xorg/Xorg.0.log"
if [[ -f $LOGFILE ]]; then
  echo -e "\n>>> Checking Xorg log for errors/warnings..."
  grep -E "(EE|WW)" "$LOGFILE" | head -30
else
  echo "Xorg log file not found at $LOGFILE"
fi

echo -e "\n>>> Script finished. Please REBOOT and then try 'startx' again."
