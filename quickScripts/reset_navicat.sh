#!/bin/bash

# Author: NakamuraOS
# https://github.com/nakamuraos
# Latest update: 30/03/2022
# Tested on Navicat 15.x, 16.x on Linux

RED="\e[1;31m"
ENDCOLOR="\e[0m"

echo -e "${RED}"
echo -e "======================================="
echo -e "|           !!! WARNING !!!           |"
echo -e "======================================="
echo -e "| All data can be destroy.            |"
echo -e "| Always backup before continue.      |"
echo -e "======================================="
echo -e "${ENDCOLOR}"

echo "Reset trial & clear all data settings."
read -p "Are you sure? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Cleaning..."
  # Backup
  cp ~/.config/dconf/user ~/.config/dconf/user.bk
  cp ~/.config/navicat/Premium/preferences.json ~/.config/navicat/Premium/preferences.json.bk
  # Clear data in dconf
  dconf reset -f /com/premiumsoft/navicat-premium/
  # Remove data fields in config file
  sed -i -E 's/,?"([A-Z0-9]+)":\{([^\}]+)},?//g' ~/.config/navicat/Premium/preferences.json
  # Done
  echo "Done."
else
  echo "Aborted."
fi

