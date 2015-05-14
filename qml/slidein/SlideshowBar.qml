import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: bar

	// Background/Border color
	color: colour_slidein_bg
	border.width: 1
	border.color: colour_slidein_border

	// Set position (we pretend that rounded corners are along the bottom edge only, that's why visible y is off screen)
	x: -1
	y: -height

	// Adjust size
	width: background.width+2
	height: pause.height+20

	CustomButton {
		id: pause
		x: 10
		y: 10
		text: "Pause Slideshow"
	}

	Rectangle {
		id: volumerect
		color: "#00000000"
		width: childrenRect.width
		y: 10
		height: pause.height
		x: (bar.width-width)/2

		Row {
			spacing: 5
			Text {
				color: "white"
				text: "Music Volume:"
				y: (volumerect.height-height)/2
			}
			CustomSlider {
				id: volume
				minimumValue: 0
				maximumValue: 100
				stepSize: 1
				scrollStep: 5
				value: 80
				y: (volumerect.height-height)/2
			}
			Text {
				color: "white"
				text: "" + volume.value + "%"
				y: (volumerect.height-height)/2
			}
		}
	}

	CustomButton {
		id: exit
		x: bar.width-width-10
		y: 10
		text: "Exit Slideshow"
		onClickedButton: stopSlideshow()
	}

	function showBar() {
		if(bar.y <= -bar.height && slideshowRunning)
			showBarAni.start()
	}
	function hideBar() {
		hideBarAni.start()
	}

	function stopSlideshow() {
		hideBar()
		slideshowRunning = false
		blocked = false
		softblocked = 0
	}

	PropertyAnimation {
		id: hideBarAni
		target: bar
		property: "y"
		to: -bar.height
		onStopped: bar.y = -bar.height-safetyDistanceForSlidein
	}
	PropertyAnimation {
		id: showBarAni
		target: bar
		property: "y"
		from: -bar.height
		to: -1
		onStarted: hideBarAni.stop()
	}

}
