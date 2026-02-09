#!/usr/bin/bash
set +e

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

pkill -f xdg-desktop-portal-wlr
pkill -f xdg-desktop-portal-gtk
pkill -f xdg-desktop-portal

# Set desktop environment for other apps
export XDG_CURRENT_DESKTOP=wlroots
export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

# Update dbus environment for portals and other services
dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR

# dinitctl --user setenv WAYLAND_DISPLAY="$WAYLAND_DISPLAY"
# dinitctl --user setenv DISPLAY="$DISPLAY"
# dinitctl --user setenv XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
# dinitctl --user setenv XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP"

/usr/libexec/xdg-desktop-portal-wlr &
sleep 1

/usr/libexec/xdg-desktop-portal-gtk &
sleep 1

/usr/libexec/xdg-desktop-portal &
