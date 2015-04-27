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
			width: (metaData.x == -metaData.width ? settings.menusensitivity*3 : metaData.width)
			hoverEnabled: true

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: if(softblocked == 0) showMetadata()
			}

		}

		// THUMBNAILBAR
		MouseArea {
			x: 0
			y: (thumbnailBar.y == background.height ? background.height-settings.menusensitivity*3 : background.height-thumbnailBar.height)
			width: thumbnailBar.width
			height: (thumbnailBar.y == background.height ? settings.menusensitivity*3 : thumbnailBar.height)
			hoverEnabled: true

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  thumbnailBar
					property: (softblocked == 0 ? (settings.thumbnailKeepVisible == false ? "y" : "") : "")
					to: background.height-thumbnailBar.height
				}
			}

		}

		// MAINMENU
		MouseArea {
			x: mainmenu.x
			y: 0
			width: mainmenu.width
			height: (mainmenu.y > -mainmenu.height ? mainmenu.height : settings.menusensitivity*3)
			hoverEnabled: true
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  mainmenu
					property: (softblocked == 0 ? "y" : "")
					to: -mainmenu.radius
				}
			}
		}

		// QUICKSETTINGS
		MouseArea {
			x: (quicksettings.x == background.width ? background.width-settings.menusensitivity*3 : background.width-quicksettings.width)
			y: quicksettings.y
			width: (quicksettings.x == background.width ? settings.menusensitivity*3 : quicksettings.width)
			height: quicksettings.height
			hoverEnabled: true
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  quicksettings
					property: (softblocked == 0 ? "x" : "")
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
		property: (quicksettings.dontAnimateComboboxOpened ? "" : "x")
		to: background.width
	}

}
