#!/bin/bash

# Встановлюємо X-сервер та утиліти
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm xorg-server xorg-xinit xterm xorg-xrandr xorg-xinput xorg-xsetroot

# BSPWM + sxhkd
sudo pacman -S --noconfirm bspwm sxhkd

# Терміни + інше
sudo pacman -S --noconfirm kitty neofetch nitrogen picom dmenu

# NVIDIA
sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

# Створюємо конфіг для bspwm
mkdir -p ~/.config/bspwm ~/.config/sxhkd

cat > ~/.config/bspwm/bspwmrc <<EOF
#!/bin/bash
sxhkd &
picom &
nitrogen --restore &
exec bspwm
EOF
chmod +x ~/.config/bspwm/bspwmrc

cat > ~/.config/sxhkd/sxhkdrc <<EOF
super + Return
  kitty
super + {h,j,k,l}
  bspc node -f {west,south,north,east}
EOF

# .xinitrc
cat > ~/.xinitrc <<EOF
exec bspwm
EOF

echo "✅ Готово. Тепер запускай: startx"
