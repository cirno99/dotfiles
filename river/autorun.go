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
		// exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/./PID=83980769_鯨注意報_UID=8356367_p0.jpg"),
		// exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/./PID=84368199_四_UID=19389056_p0.jpg"),
		exec.Command("swaybg", "-m", "fill", "-i", "/home/cirno99/backup/wallpapers/pixiv/2020/./PID=82597614_梅雨隠れの君_UID=2241258_p0.jpg"),
		exec.Command("dufs", "/home/cirno99/geekdoc/01-专栏课", "--allow-search", "--allow-symlink"),
		// something I saw others did. I don't know why.

		exec.Command("dufs", "/home/cirno99/Code/Study/sec/PeiQi-WIKI-Book/docs/.vuepress/dist", "--allow-search", "-p", "5001"),
		exec.Command("dufs", "/home/cirno99/Code/Study/Java-learning/docs/.vitepress/dist", "--allow-search", "-p", "5002"),
		exec.Command("dufs", "/home/cirno99/Code/Study/JavaGuide/dist", "--allow-search", "-p", "5003"),
		exec.Command("xrdb", "-load", "~/.Xresources"),
		exec.Command(
			"dbus-update-activation-environment",
			"SEATD_SOCK",
			"DISPLAY",
			"WAYLAND_DISPLAY",
			"XDG_SESSION_TYPE",
			"XDG_CURRENT_DESKTOP",
			"DBUS_SESSION_BUS_ADDRESS",
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
		exec.Command("river-luatile"),

		// the layouting engine for river
		// exec.Command(
		// 	"river-bsp-layout",
		// 	"--inner-gap",
		// 	"3",
		// 	"--outer-gap",
		// 	"3",
		// ),
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
