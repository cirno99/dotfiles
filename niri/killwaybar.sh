#!/bin/sh
killall -$1 waybar || waybar -c ~/.config/niri/waybar_catppuccin/config-niri.json  -s ~/.config/niri/waybar_catppuccin/niri_style.css

