
/***************************************************************************************************
 *                                                                                                 *
 * CODE TAKEN FROM https://gist.github.com/webmaster128/d32a278d4037a72dd47a AND ADJUSTED SLIGHTLY *
 *                                                                                                 *
 ***************************************************************************************************/

import QtQuick 2.3
import QtQuick.Controls.Private 1.0

// TooltipArea.qml
// This file contains private Qt Quick modules that might change in future versions of Qt
// Tested on: Qt 5.4.1

MouseArea {
	id: _root
	property string text: ""
	property int waitbefore: 500

	anchors.fill: parent
	hoverEnabled: _root.enabled

	onExited: Tooltip.hideText()
	onCanceled: Tooltip.hideText()

	Timer {
		interval: parent.waitbefore
		running: _root.enabled && _root.containsMouse && _root.text.length
		// The <span></span> part forces html rendering and adds dynamic linebreaks. Otherwise long lines may not be wrapped at all.
		onTriggered: Tooltip.showText(_root, Qt.point(_root.mouseX, _root.mouseY), "<span></span>" + _root.text)
	}
}
