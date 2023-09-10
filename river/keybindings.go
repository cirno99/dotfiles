package main

import (
	"os"
	"os/exec"
	"sync"
)

const (
	MAP      = "map"
	NORMAL   = "normal"
	MAPP     = "map-pointer"
	SPAWN    = "spawn"
	RIVERCTL = "riverctl"
)

var config, _ = os.UserConfigDir()

// mouseBindings function ﳑ Bindings for mouse
func mouseBindings(mwg *sync.WaitGroup) {
	allCMDs := []*exec.Cmd{
		exec.Command(RIVERCTL, MAPP, NORMAL, "Super", "BTN_LEFT", "move-view"),
		exec.Command(RIVERCTL, MAPP, NORMAL, "Super", "BTN_RIGHT", "resize-view"),
	}

	runner(allCMDs)

	mwg.Done()
}

// keyBindings function ﳑ setting bindings for keyboard
func keyBindings(mwg *sync.WaitGroup) {
	// Default Apps
	term := "footclient"
	nuterm := "footclient -e fish"
	// alacrittyTerm := "WAYLAND_DISPLAY=alacritty alacritty --option font.size=7 &"
	// tdropAlacritty := "WAYLAND_DISPLAY=no tdrop -mta -h 70% -w 50% alacritty"
	wezTerm := "WAYLAND_DISPLAY=no wezterm"
	tdropWezTerm := "WAYLAND_DISPLAY=no tdrop -mta -h 70% -w 50% wezterm"
	killwaybar := "killall -SIGUSR1 waybar || waybar -c ~/.config/river/waybar_catppuccin/config-river.json  -s ~/.config/river/waybar_catppuccin/river_style.css"
	// launcher := "wofi --show drun --style=/home/cirno99/.config/wofi/styles.css"
	launcher := "fish -c kickoff"
	netman := "networkmanager_dmenu"
	clipboardManager := "clipman pick -t wofi"
	changeWallpaper := "sh /home/cirno99/.config/river/change_wallpaper.sh"
	cycleFullScreenNext := "riverctl toggle-fullscreen; riverctl focus-view next; riverctl toggle-fullscreen"
	cycleFullScreenPrev := "riverctl toggle-fullscreen; riverctl focus-view previous; riverctl toggle-fullscreen"
	grimSelect := "sh /home/cirno99/.config/river/screenshots.sh"
	wayshot := "grim-cli copy"
	waylogout := "wlogout"
	// List of Keybinings
	allCMDs := []*exec.Cmd{
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "R", SPAWN, config+"/river/init"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Return", SPAWN, term),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "T", SPAWN, tdropWezTerm),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "backslash", SPAWN, nuterm),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "Return", SPAWN, wezTerm),
		//exec.Command(RIVERCTL, MAP, NORMAL, "Super", "W", SPAWN, browser),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "D", SPAWN, launcher),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "B", SPAWN, killwaybar),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "N", SPAWN, netman),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "L", SPAWN, swayLock),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "V", SPAWN, clipboardManager),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "E", SPAWN, grimSelect),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "X", SPAWN, waylogout),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "E", SPAWN, wayshot),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super", "B", SPAWN, favoRofi),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "B", SPAWN, favoClipboard),
		// wallpaper
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "N", SPAWN, changeWallpaper),

		// view focus control
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "J", "focus-view", "next"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "K", "focus-view", "previous"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Tab", SPAWN, cycleFullScreenNext),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "Tab", SPAWN, cycleFullScreenPrev),

		// bump focused view to the top of the stack
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Space", "zoom"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "Q", "close"),

		// output focus control
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "O", "focus-output", "next"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Comma", "focus-output", "previous"),

		// send view to output
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "O", "send-to-output", "next"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "Comma", "send-to-output", "previous"),

		// resize the main ratio of rivertile
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "H", "send-layout-cmd", "rivertile", "main-ratio -0.05"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "L", "send-layout-cmd", "rivertile", "main-ratio +0.05"),

		// change the amount of views in main in rivertile
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "H", "rivertile", "main-count +1"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "L", "rivertile", "main-count -1"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "H","send-layout-cmd",  "rivertile", "main-location top"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "L","send-layout-cmd",  "rivertile", "main-location left"),
		// // move views
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt", "H", "move", "left", "100"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt", "J", "move", "down", "100"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt", "K", "move", "up", "100"),
		// exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt", "L", "move", "right", "100"),
		//

		// snap views
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Control", "H", "snap", "left"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Control", "J", "snap", "down"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Control", "K", "snap", "up"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Control", "L", "snap", "right"),

		// move views
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Shift", "H", "resize", "horizontal -100"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Shift", "J", "resize", "vertical 100"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Shift", "K", "resize", "vertical -100"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Alt+Shift", "L", "resize", "horizontal 100"),

		// toggle layouts
		exec.Command(RIVERCTL, MAP, NORMAL, "Super+Shift", "F", "toggle-float"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "F", "toggle-fullscreen"),

		// Change layout orientation
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Up", "send-layout-cmd", "rivertile", "main-location top"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Right", "send-layout-cmd", "rivertile", "main-location right"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Down", "send-layout-cmd", "rivertile", "main-location bottom"),
		exec.Command(RIVERCTL, MAP, NORMAL, "Super", "Left", "send-layout-cmd", "rivertile", "main-location left"),

		// media keys
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86AudioMedia", SPAWN, "playerctl play-pause"),
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86AudioPlay", SPAWN, "playerctl play-pause"),
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86AudioPrev", SPAWN, "playerctl previous"),
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86AudioNext", SPAWN, "playerctl next"),

		// volume keys
		exec.Command(
			RIVERCTL,
			MAP,
			NORMAL,
			"None",
			"XF86AudioRaiseVolume",
			SPAWN,
			"pactl set-sink-volume @DEFAULT_SINK@ +5%",
		),
		exec.Command(
			RIVERCTL,
			MAP,
			NORMAL,
			"None",
			"XF86AudioLowerVolume",
			SPAWN,
			"pactl set-sink-volume @DEFAULT_SINK@ -5%",
		),
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86AudioMute", SPAWN, "pactl set-sink-mute @DEFAULT_SINK@ toggle"),

		// brightness keys
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86MonBrightnessUp", SPAWN, "brightnessctl s 3%+"),
		exec.Command(RIVERCTL, MAP, NORMAL, "None", "XF86MonBrightnessDown", SPAWN, "brightnessctl s 3%-"),
	}
	runner(allCMDs)
	mwg.Done()
}
