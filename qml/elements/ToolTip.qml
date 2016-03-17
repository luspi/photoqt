import QtQuick 2.3

MouseArea {
	id: tooltip_top
	property string text: ""
	property int waitbefore: 500

	anchors.fill: parent
	hoverEnabled: tooltip_top.enabled

	onExited: globaltooltip.hideText()
	onCanceled: globaltooltip.hideText()

	Timer {
		interval: parent.waitbefore
		running: tooltip_top.enabled && tooltip_top.containsMouse && tooltip_top.text.length
		// The <span></span> part forces html rendering and adds dynamic linebreaks. Otherwise long lines may not be wrapped at all.
		onTriggered: globaltooltip.showText(tooltip_top, Qt.point(tooltip_top.mouseX, tooltip_top.mouseY), "<span></span>" + tooltip_top.text)
	}

}
