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
		// Setting wallpaper (use 'ln -P' to an image here.)
		// exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/PID=86036589_殻-KARA-_UID=4094653_p1.jpg"),
		// exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/PID=82761669_Corner_UID=19920821_p0.png"),
		exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/PID=81519241_雨の休日_UID=3725576_p0.png"),
		// exec.Command("swaybg", "-c", "#"+rosePine["base"]),

		// I really hate this thing. But for now I cannot replace it! :(
		// exec.Command("tor"),

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
			"10",
			"--width",
			"350",
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
			config+"/river/waybar/config.json",
			"-s",
			config+"/river/waybar/style.css",
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
		// exec.Command(
		// 	"clash-verge",
		// ),
		exec.Command(
			"clash",
		),
		exec.Command(
			"dxreminders",
		),
		exec.Command(
			"kanshi",
		),
		exec.Command(
			"env",
			"WINIT_UNIX_BACKEND=x11",
			"alacritty",
			"-e",
			"zld",
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
