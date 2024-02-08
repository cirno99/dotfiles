#!/bin/sh
killall -$1 waybar || waybar -c ~/.config/river/waybar_catppuccin/config-river.json  -s ~/.config/river/waybar_catppuccin/river_style.css

