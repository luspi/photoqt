import QtQuick 2.3

// Convenience Item, so that not every single description text has to be styled individually (they are all the same)
Text {

	color: enabled ? colour.text : colour.disabled
	font.pointSize: 10
	wrapMode: Text.WordWrap
	textFormat: Text.StyledText

}
