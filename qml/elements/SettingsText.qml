import QtQuick 2.3

// Convenience Item, so that not every single description text has to be styled individually (they are all the same)
Text {

	color: colour.text
	font.pointSize: global_fontsize_normal
	wrapMode: Text.WordWrap
	textFormat: Text.StyledText

}
