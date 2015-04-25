function handleKeyPress(key,mod) {

	var txt = ""
	var normalkey = false

	if(mod & Qt.ControlModifier)
		txt += "Ctrl+"
	if(mod & Qt.AltModifier)
		txt += "Alt+"
	if(mod & Qt.ShiftModifier)
		txt += "Shift+"
	if(mod & Qt.MetaModifier)
		txt += "Meta+"
	if(mod & Qt.KeypadModifier)
		txt += "Keypad+"
	if(key === Qt.Key_Escape) {
		normalkey = true
		txt += "Escape";
	} else if(key === Qt.Key_Right) {
		normalkey = true
		txt += "Right";
	} else if(key === Qt.Key_Left) {
		normalkey = true
		txt += "Left";
	} else if(key === Qt.Key_Up) {
		normalkey = true
		txt += "Up";
	} else if(key === Qt.Key_Down) {
		normalkey = true
		txt += "Down";
	} else if(key === Qt.Key_Space) {
		normalkey = true
		txt += "Space";
	} else if(key === Qt.Key_Delete) {
		normalkey = true
		txt += "Delete";
	} else if(key === Qt.Key_Home) {
		normalkey = true
		txt += "Home";
	} else if(key === Qt.Key_End) {
		normalkey = true
		txt += "End";
	} else if(key === Qt.Key_PageUp) {
		normalkey = true
		txt += "Page Up";
	} else if(key === Qt.Key_PageDown) {
		txt += "Page Down";
		normalkey = true
	} else if(key === Qt.Key_Insert) {
		normalkey = true
		txt += "Insert";
	} else if(key === Qt.Key_Tab || key === Qt.Key_Backtab) {
		normalkey = true
		txt += "Tab"
	} else if(key === Qt.Key_Return) {
		normalkey = true
		txt += "Return"
	} else if(key === Qt.Key_Enter) {
		normalkey = true
		txt += "Enter"
	} else if(key < 1000) {
		normalkey = true
		txt += String.fromCharCode(key)
	} else
		normalkey = false

	return [normalkey,txt]

}
