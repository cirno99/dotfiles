FNAME=~/Pictures/Screenshots/shot-$(date +'%s_screenshot.png') 

grimblast --notify copysave area "$FNAME"
ksnip -e "$FNAME" &
