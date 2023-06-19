#!/bin/sh

addr=`hyprctl activewindow -j | jq '[.address]|@tsv' -r | sed 's/^/address:/'` 
echo $addr
hyprctl setprop $addr alpha 0.9 
notify-send "👓 Turning active window alpha on"
