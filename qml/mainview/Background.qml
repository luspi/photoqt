import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	id: background
	color: "#AA000000"

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true

		// Hides everything when no other area is hovered
		onPositionChanged: {
			hideEverything()
		}

		// METADATA
		MouseArea {
			x: 0
			y: metaData.y
			height: metaData.height
			width: metaData.width
			hoverEnabled: true

			MouseArea {
				x: 0
				y: 0
				height: parent.height
				width: 25
				hoverEnabled: true
				onEntered: showMetadata()
			}

		}

		// THUMBNAILBAR
		MouseArea {
			x: 0
			y: background.height-thumbnailBar.height
			width: thumbnailBar.width
			height:thumbnailBar.height
			hoverEnabled: true

			MouseArea {
				x: 0
				y: parent.height-50
				width: parent.width
				height: 50
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  thumbnailBar
					property: (settings.thumbnailKeepVisible == 0 ? "y" : "");
					to: background.height-thumbnailBar.height
				}
			}

		}

		// MAINMENU
		MouseArea {
			x: mainmenu.x
			y: 0
			width: mainmenu.width
			height: mainmenu.height
			hoverEnabled: true
			MouseArea {
				x: 0
				y: 0
				width: parent.width
				height: 50
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  mainmenu
					property: "y"
					to: -mainmenu.radius
				}
			}
		}

		// QUICKSETTINGS
		MouseArea {
			x: parent.width-quicksettings.width
			y: quicksettings.y
			width: quicksettings.width
			height: quicksettings.height
			hoverEnabled: true
			MouseArea {
				x: quicksettings.width-50
				y: 0
				width: 50
				height: parent.height
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  quicksettings
					property: "x"
					onStarted: quicksettings.setData()
					to: (settings.quickSettings ? (background.width-quicksettings.width+quicksettings.radius) : background.width)
				}
			}
		}

	}

	// Show elements
	function showMetadata() {
		metadata_show.start()
	}
	PropertyAnimation {
		id: metadata_show
		target: metaData
		property: "x"
		to: -metaData.radius
	}

	// Hide elements

	function hideEverything() {
		hideThumbnailBar.start()
		if(settingssession.value("metadatakeepopen") === false) hideMetaData.start()
		hideMainmenu.start()
		hideQuicksettings.start()
	}
	function hideMetadata() {
		if(settingssession.value("metadatakeepopen") === true)
			settingssession.setValue("metadatakeepopen",false)
		metaData.uncheckCheckbox()
		hideMetaData.start()
	}

	PropertyAnimation {
		id: hideThumbnailBar
		target:  thumbnailBar
		property: (settings.thumbnailKeepVisible === false ? "y" : "");
		to: background.height
	}
	PropertyAnimation {
		id: hideMetaData
		target: metaData
		property: "x"
		to: -metaData.width
	}
	PropertyAnimation {
		id: hideMainmenu
		target: mainmenu
		property: "y"
		to: -mainmenu.height
	}
	PropertyAnimation {
		id: hideQuicksettings
		target: quicksettings
		property: "x"
		to: background.width
	}

}
