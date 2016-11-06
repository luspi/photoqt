function gotUpdatedTouchGesture(startPoint, endPoint, type, numFingers, duration, path) {

	verboseMessage("Shortcuts::gotUpdatedTouchGesture()", startPoint + " / " + endPoint + " / " + type + " / " + numFingers + " / " + duration + " / " + path)


	settingsmanager.updateTouchGesture(numFingers, type, path)

}

function gotFinishedTouchGesture(startPoint, endPoint, type, numFingers, duration, path) {

	verboseMessage("Shortcuts::gotFinishedTouchGesture()", startPoint + " / " + endPoint + " / " + type + " / " + numFingers + " / " + duration + " / " + path)

	// distance -> currently unused
	var dx = endPoint.x-startPoint.x;
	var dy = endPoint.y-startPoint.y;

	var combo = numFingers + "::" + type + "::" + path.join("");

	console.log(combo)

	if(!blockedSystem) {
		if(blocked) {
			checkForSystemShortcut(combo)
		} else if(combo in touchshortcutfile)
			execute(touchshortcutfile[combo][1],touchshortcutfile[combo][0],true)
	}

	settingsmanager.finishedTouchGesture(numFingers, type, path)

}
