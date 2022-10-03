package main

import (
	"os/exec"
	"sync"
)

func setTheme(mwg *sync.WaitGroup) {
	allCMDs := []*exec.Cmd{
		exec.Command(RIVERCTL, "background-color", "0x"+rosePine["base"]),
		exec.Command(RIVERCTL, "border-color-focused", "0x"+rosePine["hlHigh"]),
		exec.Command(RIVERCTL, "border-color-unfocused", "0x"+rosePine["base"]),
		exec.Command(RIVERCTL, "border-color-urgent", "0x"+rosePine["love"]),
		exec.Command(RIVERCTL, "border-width", "3"),
		exec.Command(RIVERCTL, "xcursor-theme", "'cutefish-light'", "24"),
	}

	runner(allCMDs)

	mwg.Done()
}

var rosePine = map[string]string{
	"base":    "191724",
	"surface": "1f1d2e",
	"overlay": "26233a",
	"muted":   "6e6a86",
	"subtle":  "908caa",
	"text":    "e0def4",
	"love":    "eb6f92",
	"gold":    "f6c177",
	"rose":    "a569bd",
	"pine":    "64b5f6",
	"foam":    "9ccfd8",
	"iris":    "c4a7e7",
	"hlLow":   "21202e",
	"hlMed":   "403d52",
	"hlHigh":  "524f67",
}
