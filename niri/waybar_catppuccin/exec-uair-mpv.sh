#!/bin/sh
nohup mpv ~/Music/WhiteNoise --shuffle --loop-file=20 --reset-on-next-file=loop-file --input-ipc-server=/tmp/mpvsocket --pause >> /dev/null &
# PROC_KILL_LIST=bilibili,telegram-deskto ~/.cargo/bin/uair
PROC_KILL_LIST=bilibili ~/.cargo/bin/uair
