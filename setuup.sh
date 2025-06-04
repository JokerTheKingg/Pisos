#!/bin/bash

echo "🔍 Перевірка наявності важливих пакетів..."
for pkg in xorg xorg-xinit bspwm sxhkd xterm nvidia nvidia-utils; do
    if ! pacman -Q $pkg &>/dev/null; then
        echo "❌ Не встановлено: $pkg"
    else
        echo "✅ Встановлено: $pkg"
    fi
done

echo -e "\n🧠 Перевірка .xinitrc"
if [[ -f "$HOME/.xinitrc" ]]; then
    echo "Знайдено ~/.xinitrc:"
    cat "$HOME/.xinitrc"
else
    echo "❌ Немає файлу ~/.xinitrc"
fi

echo -e "\n🧠 Перевірка bspwmrc"
if [[ -f
