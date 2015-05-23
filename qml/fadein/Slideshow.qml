import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: slideshow

	anchors.fill: background
	color: colour_fadein_block_bg

	opacity: 0
	visible: false

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: hideSlideshowAni.start()
	}

	Rectangle {

		id: item

		// Set size
		anchors {
			fill: parent
			topMargin: Math.min((parent.height-300)/2,(parent.height-rect.height)/2)
			bottomMargin: Math.min((parent.height-300)/2,(parent.height-rect.height)/2)
			leftMargin: Math.min((parent.width-1000)/2,300)
			rightMargin: Math.min((parent.width-1000)/2,300)
		}

		// Some styling
		border.width: 1
		border.color: colour_fadein_border
		radius: 10
		color: colour_fadein_bg

		// Clicks INSIDE element doesn't close it
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
		}

		Rectangle {

			id: rect

			// Set inner area for display
			height: topcol.height+25
			width: parent.width-2*item.radius
			x: item.radius
			color: "#00000000"

			Column {

				id: topcol

				spacing: 10

				// A SCROLLABLE AREA
				Flickable {

					width: parent.width
					height: Math.min(scrollcol.height,wallpaper.height-250)
					contentHeight: scrollcol.height
					clip: true
					boundsBehavior: Flickable.DragAndOvershootBounds

					Column {

						id: scrollcol
						spacing: 15

						Rectangle { color: "#00000000"; width: 1; height: 1; }

						// HEADING
						Text {
							color: "white"
							font.pointSize: 20
							font.bold: true
							x: (rect.width-width)/2
							text: "Start a Slideshow"
						}

						Rectangle { color: "#00000000"; width: 1; height: 1; }

						// DESCRIPTION
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "There are several settings that can be adjusted for a slideshow, like the time between the image, if and how long the transition between the images should be, and also a music file can be specified that is played in the background."
						}
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "Once you have set the desired options, you can also start a slideshow the next time via 'Quickstart', i.e. skipping this settings window."
						}

						// TIME BETWEEN IMAGES
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							font.pointSize: 15
							font.bold: true
							text: "Time in between"
						}
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "Adjust the time between the images. The time specified here is the amount of time the image will be completely visible, i.e. the transitioning (if set) is not part of this time."
						}

						// Adjust the time in between (slider/spinbox)
						Rectangle {
							color: "#00000000"
							x: (rect.width-width)/2
							width: childrenRect.width
							height: childrenRect.height
							Row {
								spacing: 5
								CustomSlider {
									id: timeslider
									x: (rect.width-width)/2
									width: rect.width/3
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
						}

						// SMOOTH TRANSITION OF IMAGES
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							font.pointSize: 15
							font.bold: true
							text: "Smooth Transition"
						}
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "Here you can set, if you want the images to fade into each other, and how fast they are to do that."
						}

						// Slider to adjust transition time
						Rectangle {
							color: "#00000000"
							x: (rect.width-width)/2
							width: childrenRect.width
							height: childrenRect.height
							Row {
								spacing: 5
								Text {
									color: "white"
									text: "No Transition"
								}
								CustomSlider {
									id: transitionslider
									x: (rect.width-width)/2
									width: rect.width/3
									minimumValue: 0
									maximumValue: 15
									scrollStep: 1
									stepSize: 1
									tickmarksEnabled: true
									value: settings.slideShowTransition
								}
								Text {
									color: "white"
									text: "Long Transition"
								}
							}
						}

						// SHUFFLE AND LOOP
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							font.pointSize: 15
							font.bold: true
							text: "Shuffle and Loop"
						}
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "If you want PhotoQt to loop over all images (i.e., once it shows the last image it starts from the beginning), or if you want PhotoQt to load your images in random order, you can check either or both boxes below. Note, that no image will be shown twice before every image has been shown once."
						}

						// Checkboxes to en-/disable it
						CustomCheckBox {
							id: loop
							text: "Loop over images"
							checkedButton: settings.slideShowLoop
							x: (rect.width-width)/2
						}
						CustomCheckBox {
							id: shuffle
							text: "Shuffle images"
							checkedButton: settings.slideShowShuffle
							x: (rect.width-width)/2
						}

						// HIDE QUICKINFOS
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							font.pointSize: 15
							font.bold: true
							text: "Hide Quickinfo"
						}

						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "Depending on your setup, PhotoQt displays some information at the top edge, like position in current directory or file path/name. Here you can disable them temporarily for the slideshow."
						}

						CustomCheckBox {
							id: quickinfo
							text: "Hide Quickinfos"
							checkedButton: settings.slideShowHideQuickinfo
							x: (rect.width-width)/2
						}

						// BACKGROUND MUSIC
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							font.pointSize: 15
							font.bold: true
							text: "Background Music"
						}
						Text {
							color: "white"
							width: rect.width
							wrapMode: Text.WordWrap
							text: "Some might like to listen to some music while the slideshow is running. Here you can select a music file you want to be played in the background."
						}
						// Checkbox to enable music
						CustomCheckBox {
							id: musiccheckbox
							x: (rect.width-width)/2
							checkedButton: (settings.slideShowMusicFile != "")
							text: "Enable Music"
						}
						// Area displaying music file path and option to change it
						Rectangle {
							color: enabled ? "#11999999" : "#11ffffff"
							width: rect.width/2
							enabled: musiccheckbox.checkedButton
							x: rect.width/4
							height: musictxt.height+20
							radius: 5
							border.color: "#303030"
							Text {
								id: musictxt
								x: 15
								clip: true
								elide: Text.ElideLeft
								width: parent.width-30
								y: (parent.height-height)/2
								color: parent.enabled ? "white" : "grey"
								text: settings.slideShowMusicFile
							}
							Text {
								id: emptymusic
								x: 15
								visible: musictxt.text == ""
								width: parent.width-30
								y: (parent.height-height)/2
								color: "grey"
								text: "Click here to select music file..."
							}
							// Click on area offers option to select new file
							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: selectNewMusicFile()
							}
						}

						Rectangle { color: "#00000000"; width: 1; height: 1; }

					}

				} // END FLickable


				Rectangle {
					color: "grey"
					width: rect.width
					height: 1
				}

				Rectangle {
					color: "#00000000"
					width: childrenRect.width
					height: childrenRect.height
					x: (parent.width-width)/2

					Row {
						spacing: 10
						CustomButton {
							id: okay
							text: "Okay, lets start"
							onClickedButton: simulateEnter();
						}
						CustomButton {
							text: "Wait, maybe later"
							onClickedButton: hideSlideshow()
						}
						CustomButton {
							text: "Save changes, but don't start just yet"
							onClickedButton: hideSlideshowAndRememberSettings()
						}
					}
				}

			}

		}	// END id: rect

	}

	function selectNewMusicFile() {
		var ret = getanddostuff.getFilename("Select music file...","/home/luspi/Musik","Music Files (*.mp3 *.flac *.ogg *.wav);;All Files (*.*)")
		if(ret !== "")
			musictxt.text = ret
	}

	function simulateEnter() {
		saveSettings()
		hideSlideshow()

		// The slideshowbar handles the slideshow (as it has an active role during the slideshow)
		slideshowbar.startSlideshow()

	}

	function quickstart() {
		if(thumbnailBar.currentFile == "") return;
		loadSettings()
		simulateEnter()
	}

	function showSlideshow() {
		if(thumbnailBar.currentFile == "") return;
		loadSettings()
		showSlideshowAni.start()
	}

	function hideSlideshow() {
		hideSlideshowAni.start()
	}
	function hideSlideshowAndRememberSettings() {
		saveSettings()
		hideSlideshowAni.start()
	}

	function saveSettings() {
		settings.slideShowTime = timeslider.value
		settings.slideShowTransition = transitionslider.value
		settings.slideShowLoop = loop.checkedButton
		settings.slideShowShuffle = shuffle.checkedButton
		settings.slideShowHideQuickinfo = quickinfo.checkedButton
		settings.slideShowMusicFile = (musiccheckbox.checkedButton ? musictxt.text : "")
	}
	function loadSettings() {
		timeslider.value = settings.slideShowTime
		transitionslider.value = settings.slideShowTransition
		loop.checkedButton = settings.slideShowLoop
		shuffle.checkedButton = settings.slideShowShuffle
		quickinfo.checkedButton = settings.slideShowHideQuickinfo
		musiccheckbox.checkedButton = settings.slideShowMusicFile
		musictxt.text = settings.slideShowMusicFile
	}

	PropertyAnimation {
		id: hideSlideshowAni
		target:  slideshow
		property: "opacity"
		to: 0
		onStopped: {
			visible = false
			if(!slideshowRunning) blocked = false
		}
	}

	PropertyAnimation {
		id: showSlideshowAni
		target:  slideshow
		property: "opacity"
		to: 1
		onStarted: {
			visible = true
			blocked = true
		}
	}

}
