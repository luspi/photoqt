import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: statusbar

//	anchors.left: parent.left
//	anchors.bottom: parent.bottom
//	anchors.right: parent.right
//	height: 50

	color: "#44000000"

	signal displayIcons();
	signal displayList();

	property int zoomlevel: zoom.getZoomLevel()

	TweaksZoom {
		id: zoom
		anchors.left: parent.left
		anchors.leftMargin: 10
		onUpdateZoom: zoomlevel = level
	}

	TweaksPreview {
		id: preview
		anchors.right: viewmode.left
		anchors.rightMargin: 30
	}


	TweaksViewMode {
		id: viewmode
		anchors.right: parent.right
		anchors.rightMargin: 10
	}

	function getMode() {
		return preview.getMode()
	}

	function getView() {
		return viewmode.getView()
	}

}
