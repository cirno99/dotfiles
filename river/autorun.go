package main

import (
	"os/exec"
	"sync"
)

// autorun function ﳑ will start running everything at startup.
func autorun(mwg *sync.WaitGroup) {
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		killProcess("waybar")
		wg.Done()
	}()
	go func() {
		killProcess("swaybg")
		wg.Done()
	}()
	wg.Wait()

	cmdList := []*exec.Cmd{
		// exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/PID=82055611_薫る六月照る水無月。_UID=2863217_p0.jpg"),
		// exec.command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/photo_2022-02-27_17-40-50.jpg"),
		exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/./PID=83980769_鯨注意報_UID=8356367_p0.jpg"),
		exec.Command("dufs", "/home/cirno99/geekdoc/01-专栏课", "--allow-search"),
		// something I saw others did. I don't know why.
		exec.Command(
			"dbus-update-activation-environment",
			"SEATD_SOCK",
			"DISPLAY",
			"WAYLAND_DISPLAY",
			"XDG_SESSION_TYPE",
			"XDG_CURRENT_DESKTOP",
		),

		// notification daemon
		exec.Command("mako",
			"--default-timeout",
			"5000",
			"--background-color",
			"#"+rosePine["pine"],
			"--border-color",
			"#"+rosePine["pine"],
			"--border-size",
			"0",
			"--font",
			"monospace",
			"--padding",
			"7",
			"--width",
			"550",
		),

		// the layouting engine for river
		exec.Command(
			"rivertile",
			"-view-padding",
			"03",
			"-outer-padding",
			"03",
		),

		exec.Command(
			"waybar",
			"-c",
			config+"/river/waybar_catppuccin/config-river.json",
			"-s",
			config+"/river/waybar_catppuccin/river_style.css",
		),

		exec.Command(
			"wl-paste",
			"-t",
			"text",
			"--watch",
			"clipman",
			"store",
		),
		exec.Command(
			"wl-paste",
			"-p",
			"-t",
			"text",
			"--watch",
			"clipman",
			"store",
			"-P",
			"store",
			"~/.local/share/clipman-primary.json",
		),
		exec.Command(
			"foot",
			"-s",
		),
		exec.Command(
			"fcitx5",
		),
		exec.Command(
			"pueued",
		),
		exec.Command(
			"clash-verge",
		),
		// exec.Command(
		// 	"clash",
		// ),
		exec.Command(
			"kanshi",
		),
	}

	// Concurrency stuff
	var swg sync.WaitGroup
	// executing all the commands... concurrently!
	for _, cmd := range cmdList {
		swg.Add(1)
		go cmdStart(cmd, &swg)
	}

	swg.Wait()
	mwg.Done()
}
