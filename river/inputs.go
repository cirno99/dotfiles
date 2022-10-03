package main

import (
	"os/exec"
	"sync"
)

func inputs(mwg *sync.WaitGroup) {
	allCMDs := []*exec.Cmd{
		exec.Command(RIVERCTL, "input", "pointer-1267-12652-ELAN0734:00_04F3:316C_Touchpad", "drag", "enabled"),
		exec.Command(RIVERCTL, "input", "pointer-1267-12652-ELAN0734:00_04F3:316C_Touchpad", "tap", "enabled"),
		exec.Command(RIVERCTL, "input", "pointer-1267-12652-ELAN0734:00_04F3:316C_Touchpad", "events", "enabled"),
		exec.Command(RIVERCTL, "input", "pointer-1267-12652-ELAN0734:00_04F3:316C_Touchpad", "natural-scroll", "disabled"),
		exec.Command(RIVERCTL, "input", "pointer-1267-12652-ELAN0734:00_04F3:316C_Touchpad", "scroll-method", "two-finger"),
	}
	runner(allCMDs)

	mwg.Done()
}
