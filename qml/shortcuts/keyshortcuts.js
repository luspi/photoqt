
var keys = "";

// Updated key combo -> check if equal to some shortcut -> execute
function updateKeyCombo(combo) {
	verboseMessage("Shortcuts::detectKeyCombo()",combo + " - " + blocked + "/" + blockedSystem + "/" + softblocked + "/" + slideshowRunning)

	if(settingsmanager.isDetectShortcutShown()) {
		settingsmanager.updateKeyShortcut(combo)
		return
	}

	if(softblocked != 0 && combo === "Escape") {
		if(slideshowRunning)
			slideshowbar.stopSlideshow()
		else
			softblocked = 0
	} else if((softblocked != 0 && !slideshowRunning) || slideshowRunning)
		return
	else if(!blockedSystem) {
		if(blocked)
			checkForSystemShortcut(combo)
		else if(combo in keyshortcutfile)
			execute(keyshortcutfile[combo][1],keyshortcutfile[combo][0]);
	}
	keys = combo

}

// simulate a shortcut event
function simulateShortcut(keys) {
	verboseMessage("Shortcuts::simulateShortcut()", keys + " - " + blocked + "/" + blockedSystem + "/" + softblocked)
	if(softblocked != 0 && combo === "Escape")
		softblocked = 0
	else if(softblocked != 0)
		return
	else if(!blockedSystem) {
		if(blocked)
			checkForSystemShortcut(keys)
		else if(keys in keyshortcutfile)
			execute(keyshortcutfile[keys][1]);
	}
}
