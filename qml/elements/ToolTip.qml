import QtQuick 2.3

MouseArea {
	id: top
	property string text: ""
	property int waitbefore: 500

	anchors.fill: parent
	hoverEnabled: top.enabled

	onExited: globaltooltip.hideText()
	onCanceled: globaltooltip.hideText()

	Timer {
		interval: parent.waitbefore
		running: top.enabled && top.containsMouse && top.text.length
		// The <span></span> part forces html rendering and adds dynamic linebreaks. Otherwise long lines may not be wrapped at all.
		onTriggered: globaltooltip.showText(top, Qt.point(top.mouseX, top.mouseY), "<span></span>" + top.text)
	}
}
