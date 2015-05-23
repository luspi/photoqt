import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.1

Rectangle {

	id: background

	// BELOW ARE FOUR ELMENETS THAT CAN ACT AS BACKGROUND.
	// ONLY ONE OF THEM IS VISIBLE AT A TIME (DEPENDING ON SETTINGS)

	// True transparency
	color: settings.composite ? getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
							  : "#00000000"
	// Fake transparency
	Image {
		anchors.fill: parent
		visible: !settings.composite && settings.backgroundImageScreenshot
		source: (!settings.composite && settings.backgroundImageScreenshot) ? "file://tmp/photoqt_screenshot_" + getanddostuff.getCurrentScreen(toplevel.windowx,toplevel.windowy) + ".jpg" : ""
		Rectangle {
			anchors.fill: parent
			visible: parent.visible
			color: getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
		}
	}

	// Background screenshot
	Image {
		visible: settings.backgroundImageUse
		anchors.fill: parent
		horizontalAlignment: settings.backgroundImageCenter ? Image.AlignHCenter : Image.AlignLeft
		verticalAlignment: settings.backgroundImageCenter ? Image.AlignVCenter : Image.AlignTop
		fillMode: settings.backgroundImageScale ? Image.PreserveAspectFit
												: (settings.backgroundImageScaleCrop ? Image.PreserveAspectCrop
													: (settings.backgroundImageStretch ? Image.Stretch
														: (settings.backgroundImageTile ? Image.Tile : Image.Pad)))
		source: settings.backgroundImagePath
		Rectangle {
			anchors.fill: parent
			visible: parent.visible
			color: getanddostuff.addAlphaToColor(Qt.rgba(settings.bgColorRed, settings.bgColorGreen, settings.bgColorBlue, settings.bgColorAlpha), settings.bgColorAlpha)
		}

	}

	// BACKGROUND COLOR
	Rectangle {
		anchors.fill: parent
		// The Qt.rgba() function IGNORES the alpha value by default (that's why above we use a custom function to add it!)
		color: Qt.rgba(settings.bgColorRed,settings.bgColorGreen,settings.bgColorBlue,settings.bgColorAlpha)
		visible: !settings.composite && !settings.backgroundImageScreenshot && !settings.backgroundImageUse
	}

	/******* END BACKGROUND ELEMENTS **********/


	width: parent.width
	height: parent.height

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
			width: (metaData.x <= -metaData.width ? settings.menusensitivity*3 : metaData.width)
			hoverEnabled: true

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered: if(softblocked == 0 && metaData.x < -metaData.width) showMetadata()
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
					from: -mainmenu.height
					property: ((softblocked == 0 && mainmenu.y < -mainmenu.height) ? "y" : "")
					to: -mainmenu.radius
				}
			}
		}

		// QUICKSETTINGS
		MouseArea {
			x: (quicksettings.x > background.width ? background.width-settings.menusensitivity*3 : background.width-quicksettings.width)
			y: quicksettings.y
			width: (quicksettings.x > background.width ? settings.menusensitivity*3 : quicksettings.width)
			height: quicksettings.height
			hoverEnabled: true
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				onEntered:
				PropertyAnimation {
					target:  quicksettings
					property: ((softblocked == 0 && quicksettings.x > background.width) ? "x" : "")
					from: background.width
					onStarted: { quicksettings.setData(); }
					to: (settings.quickSettings ? (background.width-quicksettings.width+quicksettings.radius) : background.width)
				}
			}
		}

	}

	// SLIDESHOWBAR
	MouseArea {
		x: 0
		y: 0
		width: background.width
		height: slideshowRunning ? ((slideshowbar.y <= -slideshowbar.height) ? 3*settings.menusensitivity : slideshowbar.height) : 0
		hoverEnabled: true
		onEntered: slideshowbar.showBar()
	}

	// Show elements
	function showMetadata() {
		metadata_show.start()
	}
	PropertyAnimation {
		id: metadata_show
		target: metaData
		property: "x"
		from: -metaData.width
		to: -metaData.radius
	}

	// Hide elements

	function hideEverything() {
		hideThumbnailBar.start()
		if(settingssession.value("metadatakeepopen") === false) hideMetaData.start()
		hideMainmenu.start()
		if(quicksettings.x < background.width)
			hideQuicksettings.start()
		slideshowbar.hideBar()
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
		to: -metaData.width-safetyDistanceForSlidein
	}
	PropertyAnimation {
		id: hideMainmenu
		target: mainmenu
		property: "y"
		to: -mainmenu.height-safetyDistanceForSlidein
	}
	PropertyAnimation {
		id: hideQuicksettings
		target: quicksettings
		property: (quicksettings.dontAnimateComboboxOpened ? "" : "x")
		to: background.width+safetyDistanceForSlidein
	}

}
