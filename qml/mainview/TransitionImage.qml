import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	color: "#00000000"

	width: childrenRect.width
	height: childrenRect.height

	property bool mirror: false

	property string source: ""
	onSourceChanged: {
		one_fadein.stop()
		one_fadeout.stop()
		two_fadein.stop()
		two_fadeout.stop()

		// We fade the first image in in whenever we load a new directory
		var newImageSoFadeItIn = false
		if((one.source == "" && two.source == "" && source != "")
				|| (one.source != ""
					&& (getanddostuff.removeFilenameFromPath(one.source) !== getanddostuff.removeFilenameFromPath(source))
					&& currentone == "one")
				|| (two.source != ""
					&& (getanddostuff.removeFilenameFromPath(two.source) !== getanddostuff.removeFilenameFromPath(source))
					&& currentone == "two"))
				newImageSoFadeItIn = true

		if(((slideshowRunning && settings.slideShowTransition === 0) || (!slideshowRunning && settings.transition === 0)) && !newImageSoFadeItIn) {

			if(currentone == "one") {
				one.opacity = 1
				two.opacity = 0
				one.source = source
			}
			if(currentone == "two") {
				two.opacity = 1
				one.opacity = 0
				two.source = source
			}


		} else {

			var duration = (slideshowRunning ? settings.slideShowTransition : settings.transition)*150

			// On start, the first image is always faded in
			if(newImageSoFadeItIn && ((slideshowRunning && settings.slideShowTransition === 0) || settings.transition === 0))
				duration = 300

			one_fadein.duration = duration
			one_fadeout.duration = duration
			two_fadein.duration = duration
			two_fadeout.duration = duration

			if(currentone == "one") {
				one.opacity = 1
				two.opacity = 0
				two.scale = 1
				two.visible = true
				two.source = ""
				two.source = source
				two_fadein.start()
				one_fadeout.start()
				currentone = "two"
			} else {
				two.opacity = 1
				one.opacity = 0
				one.scale = 1
				one.visible = true
				one.source = ""
				one.source = source
				one_fadein.start()
				two_fadeout.start()
				currentone = "one"
			}

		}
	}
	property string currentone: "one"

	property bool asynchronous: false
	property int fillMode: Image.PreserveAspectFit

	property size sourceSize: Qt.size(0,0);
	onSourceSizeChanged: {
		if(one.opacity != 0)
			one.sourceSize = sourceSize
		if(two.opacity != 0)
			two.sourceSize = sourceSize
	}

	function forceSourceSizeToBoth(s) {
		one.sourceSize = s
		two.sourceSize = s
	}

	signal statusChanged(var status)

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: one

		x: (Math.max(one.width,two.width)-width)/2
		y: (Math.max(one.height,two.height)-height)/2

		opacity: 1

		mirror: parent.mirror

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: two

		x: (Math.max(one.width,two.width)-width)/2
		y: (Math.max(one.height,two.height)-height)/2

		opacity: 1

		mirror: parent.mirror

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	PropertyAnimation {
		id: one_fadein
		target: one
		properties: "opacity"
		from: 0
		to: 1
		duration: 300
	}
	PropertyAnimation {
		id: two_fadein
		target: two
		properties: "opacity"
		from: 0
		to: 1
		duration: 300
	}
	PropertyAnimation {
		id: one_fadeout
		target: one
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: one.visible = false
	}
	PropertyAnimation {
		id: two_fadeout
		target: two
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: two.visible = false
	}

	function resetZoom(loadNewImage) {

		if(loadNewImage !== undefined && loadNewImage === true && ((slideshowRunning && settings.slideShowTransition != 0) || settings.transition != 0)) {
			if(currentone == "one") {
				one.scale = scale
				scale = 1
			}
			if(currentone == "two") {
				two.scale = scale
				scale = 1
			}
		} else {
			one.scale = 1
			two.scale = 1
			scale = 1
		}

	}

}
