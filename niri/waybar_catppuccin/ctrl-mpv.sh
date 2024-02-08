#!/bin/sh
~/.cargo/bin/uairctl toggle | echo '{ "command": ["cycle", "pause"] }' | socat - /tmp/mpvsocket
