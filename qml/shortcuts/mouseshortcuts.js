// An update to the gesture; not yet finished gesture!
function gotUpdatedMouseGesture(button, gesture, modifiers) {

	verboseMessage("Shortcuts::gotUpdatedMouseGesture()", button + " / " + gesture + " / " + modifiers)

	// The mouse shortcut combo
	var combo = "";

	// If modifier pressed, add to combo
	if(modifiers !== "")
		combo = modifiers + "+";

	// Set button
	combo += button

	// If there's a gesture, add to combo
	if(gesture.length > 0)
		combo += "+"
	for(var k in gesture)
		combo += gesture[k]

	// do something with combo
	console.log(combo)

}

// Finished the mouse gesture
function gotFinishedMouseGesture(startPoint, endPoint, duration, button, gesture, wheelAngleDelta, modifiers) {

	verboseMessage("Shortcuts::gotFinishedMouseGesture()", startPoint + " / " + endPoint + " / " + duration + " / " + button + " / " + gesture + " / " + wheelAngleDelta + " / " + modifiers)

	// distance -> currently unused
	var dx = endPoint.x-startPoint.x
	var dy = endPoint.y-startPoint.y

	// The mouse shortcut combo
	var combo = "";

	// If modifier pressed, add to combo
	if(modifiers !== "")
		combo = modifiers + "+";

	// Set button
	combo += button

	// If there's a gesture, add to combo
	if(gesture.length > 0)
		combo += "+"
	for(var k in gesture)
		combo += gesture[k]

	// Execute shortcut IF one is set
	if(combo in mouseshortcutfile)
		execute(mouseshortcutfile[key][1],mouseshortcutfile[key][0],true)

}
