import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

FadeInTemplate {

	id: slideshow_top

	heading: "Slideshow Setup"

	content: [

		Rectangle { color: "#00000000"; width: 1; height: 1; },

		// DESCRIPTION
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("There are several settings that can be adjusted for a slideshow, like the time between the image, if and how long the transition between the images should be, and also a music file can be specified that is played in the background.")
		},
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("Once you have set the desired options, you can also start a slideshow the next time via 'Quickstart', i.e. skipping this settings window.")
		},

		// TIME BETWEEN IMAGES
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 15
			font.bold: true
			text: qsTr("Time in between")
		},
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("Adjust the time between the images. The time specified here is the amount of time the image will be completely visible, i.e. the transitioning (if set) is not part of this time.")
		},

		// Adjust the time in between (slider/spinbox)
		Rectangle {
			color: "#00000000"
			x: (slideshow_top.contentWidth-width)/2
			width: childrenRect.width
			height: childrenRect.height
			Row {
				spacing: 5
				CustomSlider {
					id: timeslider
					x: (slideshow_top.contentWidth-width)/2
					width: slideshow_top.contentWidth/3
					minimumValue: 1
					maximumValue: 300
					scrollStep: 1
					stepSize: 1
					value: settings.slideShowTime
				}
				CustomSpinBox {
					id: timespinbox
					width: 75
					minimumValue: 1
					maximumValue: 300
					suffix: "s"
					value: timeslider.value
					onValueChanged: timeslider.value = value
				}
			}
		},

		// SMOOTH TRANSITION OF IMAGES
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 15
			font.bold: true
			text: qsTr("Smooth Transition")
		},
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("Here you can set, if you want the images to fade into each other, and how fast they are to do that.")
		},

		// Slider to adjust transition time
		Rectangle {
			color: "#00000000"
			x: (slideshow_top.contentWidth-width)/2
			width: childrenRect.width
			height: childrenRect.height
			Row {
				spacing: 5
				Text {
					color: colour.text
					font.pointSize: 10
					text: qsTr("No Transition")
				}
				CustomSlider {
					id: transitionslider
					x: (slideshow_top.contentWidth-width)/2
					width: slideshow_top.contentWidth/3
					minimumValue: 0
					maximumValue: 15
					scrollStep: 1
					stepSize: 1
					tickmarksEnabled: true
					value: settings.slideShowTransition
				}
				Text {
					font.pointSize: 10
					color: colour.text
					text: qsTr("Long Transition")
				}
			}
		},

		// SHUFFLE AND LOOP
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 15
			font.bold: true
			text: qsTr("Shuffle and Loop")
		},
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("If you want PhotoQt to loop over all images (i.e., once it shows the last image it starts from the beginning), or if you want PhotoQt to load your images in random order, you can check either or both boxes below. Note, that no image will be shown twice before every image has been shown once.")
		},

		// Checkboxes to en-/disable it
		CustomCheckBox {
			id: loop
			text: qsTr("Loop over images")
			checkedButton: settings.slideShowLoop
			x: (slideshow_top.contentWidth-width)/2
		},
		CustomCheckBox {
			id: shuffle
			text: qsTr("Shuffle images")
			checkedButton: settings.slideShowShuffle
			x: (slideshow_top.contentWidth-width)/2
		},

		// HIDE QUICKINFOS
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 15
			font.bold: true
			text: qsTr("Hide Quickinfo")
		},

		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("Depending on your setup, PhotoQt displays some information at the top edge, like position in current directory or file path/name. Here you can disable them temporarily for the slideshow.")
		},

		CustomCheckBox {
			id: quickinfo
			text: qsTr("Hide Quickinfos")
			checkedButton: settings.slideShowHideQuickinfo
			x: (slideshow_top.contentWidth-width)/2
		},

		// BACKGROUND MUSIC
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 15
			font.bold: true
			text: qsTr("Background Music")
		},
		Text {
			color: colour.text
			width: slideshow_top.contentWidth
			wrapMode: Text.WordWrap
			font.pointSize: 10
			text: qsTr("Some might like to listen to some music while the slideshow is running. Here you can select a music file you want to be played in the background.")
		},
		// Checkbox to enable music
		CustomCheckBox {
			id: musiccheckbox
			x: (slideshow_top.contentWidth-width)/2
			checkedButton: (settings.slideShowMusicFile != "")
			text: qsTr("Enable Music")
		},
		// Area displaying music file path and option to change it
		Rectangle {
			color: enabled ? getanddostuff.addAlphaToColor(colour.text_disabled,20) : getanddostuff.addAlphaToColor(colour.text,20)
			width: slideshow_top.contentWidth/2
			enabled: musiccheckbox.checkedButton
			x: slideshow_top.contentWidth/4
			height: musictxt.height+20
			radius: global_item_radius
			border.color: colour.fadein_slidein_border
			Text {
				id: musictxt
				x: 15
				clip: true
				elide: Text.ElideLeft
				width: parent.width-30
				font.pointSize: 10
				y: (parent.height-height)/2
				color: parent.enabled ? colour.text : colour.text_disabled
				text: settings.slideShowMusicFile
			}
			Text {
				id: emptymusic
				x: 15
				visible: musictxt.text == ""
				width: parent.width-30
				y: (parent.height-height)/2
				font.pointSize: 10
				color: colour.text_disabled
				text: qsTr("Click here to select music file...")
			}
			// Click on area offers option to select new file
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: selectNewMusicFile()
			}
		},

		Rectangle { color: "#00000000"; width: 1; height: 1; }
	]

	buttons: [
		Item {
			anchors.horizontalCenter: parent.horizontalCenter
			width: childrenRect.width
			Row {
				spacing: 10
				CustomButton {
					id: okay
					text: qsTr("Okay, lets start")
					onClickedButton: simulateEnter();
				}
				CustomButton {
					text: qsTr("Wait, maybe later")
					onClickedButton: hideSlideshow()
				}
				CustomButton {
					text: qsTr("Save changes, but don't start just yet")
					onClickedButton: hideSlideshowAndRememberSettings()
				}
			}
		}
	]

	function selectNewMusicFile() {
		verboseMessage("Slideshow::selectNewMusicFile()","")
		var ret = getanddostuff.getFilename(qsTr("Select music file..."),getanddostuff.getHomeDir(),qsTr("Music Files") + " (*.mp3 *.flac *.ogg *.wav);;" + qsTr("All Files") + " (*.*)")
		if(ret !== "")
			musictxt.text = ret
	}

	function simulateEnter() {

		verboseMessage("Slideshow::simulateEnter()","")

		saveSettings()
		hideSlideshow()

		// The slideshowbar handles the slideshow (as it has an active role during the slideshow)
		slideshowbar.startSlideshow()

	}

	function quickstart() {
		verboseMessage("Slideshow::quickstart()",thumbnailBar.currentFile)
		if(thumbnailBar.currentFile == "") return;
		loadSettings()
		simulateEnter()
	}

	function showSlideshow() {
		verboseMessage("Slideshow::showSlideshow()",thumbnailBar.currentFile)
		if(thumbnailBar.currentFile == "") return;
		loadSettings()
		show()
	}

	function hideSlideshow() {
		verboseMessage("Slideshow::hideSlideshow()","")
		hide()
	}
	function hideSlideshowAndRememberSettings() {
		verboseMessage("Slideshow::hideSlideshowAndRememberSettings()","")
		saveSettings()
		hide()
	}

	function saveSettings() {
		verboseMessage("Slideshow::saveSettings()","")
		settings.slideShowTime = timeslider.value
		settings.slideShowTransition = transitionslider.value
		settings.slideShowLoop = loop.checkedButton
		settings.slideShowShuffle = shuffle.checkedButton
		settings.slideShowHideQuickinfo = quickinfo.checkedButton
		settings.slideShowMusicFile = (musiccheckbox.checkedButton ? musictxt.text : "")
	}
	function loadSettings() {
		verboseMessage("Slideshow::loadSettings()","")
		timeslider.value = settings.slideShowTime
		transitionslider.value = settings.slideShowTransition
		loop.checkedButton = settings.slideShowLoop
		shuffle.checkedButton = settings.slideShowShuffle
		quickinfo.checkedButton = settings.slideShowHideQuickinfo
		musiccheckbox.checkedButton = settings.slideShowMusicFile
		musictxt.text = settings.slideShowMusicFile
	}

}
