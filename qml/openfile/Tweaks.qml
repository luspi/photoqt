import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {

	id: statusbar

	color: "#44000000"

	signal displayIcons();
	signal displayList();

	property int zoomlevel: zoom.getZoomLevel()
	property bool isHoverPreviewEnabled: preview.isHoverEnabled

	TweaksZoom {
		id: zoom
		anchors.left: parent.left
		anchors.leftMargin: 10
		onUpdateZoom: zoomlevel = level
	}

	TweaksPreview {
		id: preview
		anchors.right: thumbnail.left
		anchors.rightMargin: 10
	}

	TweaksThumbnail {
		id: thumbnail
		anchors.right: viewmode.left
		anchors.rightMargin: 10
	}


	TweaksViewMode {
		id: viewmode
		anchors.right: parent.right
		anchors.rightMargin: 10
	}

	function getView() {
		return viewmode.getView()
	}

	function getThumbnailEnabled() {
		return thumbnail.getThumbnailEnabled()
	}
	function setThumbnailChecked(s) {
		thumbnail.setThumbnailChecked(s)
	}

}
