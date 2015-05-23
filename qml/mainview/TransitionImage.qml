import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	color: "#00000000"

	width: childrenRect.width
	height: childrenRect.height

	property bool asynchronous: false
	property bool mirror: false
	property bool animated: false

	property string source: ""
	property string currentone: "one"

	property int fillMode: Image.PreserveAspectFit
	property size sourceSize: Qt.size(0,0);

	// When a filter returns an empty result, we fade out the image, reset the source (using this boolean),
	// so that after removing the filter, the image is faded in again
	property bool resetSourceToEmptyAfterFadeOut: false

	// The image source has changed
	onSourceChanged: {

		// This is usually the case, when a filter returns no results
		if(source == "") {

			resetSourceToEmptyAfterFadeOut = true

			one_fadeout.duration = 300
			one_fadeout.start()
			two_fadeout.duration = 300
			two_fadeout.start()
			three_fadeout.duration = 300
			three_fadeout.start()
			four_fadeout.duration = 300
			four_fadeout.start()

			return;

		}

		resetSourceToEmptyAfterFadeOut = false

		var _source = Qt.resolvedUrl(source)

		// Stop all animations
		one_fadein.stop()
		one_fadeout.stop()
		two_fadein.stop()
		two_fadeout.stop()
		three_fadein.stop()
		three_fadeout.stop()
		four_fadein.stop()
		four_fadeout.stop()

		// We fade the first image in in whenever we load a new directory
		var newImageSoFadeItIn = false
		if((one.source == "" && two.source == "" && three.source == "" && four.source == "" && _source != "")
				|| (one.source != ""
					&& (getanddostuff.removeFilenameFromPath(one.source) !== getanddostuff.removeFilenameFromPath(_source))
					&& currentone == "one")
				|| (two.source != ""
					&& (getanddostuff.removeFilenameFromPath(two.source) !== getanddostuff.removeFilenameFromPath(_source))
					&& currentone == "two")
				|| (three.source != ""
					&& (getanddostuff.removeFilenameFromPath(three.source) !== getanddostuff.removeFilenameFromPath(_source))
					&& currentone == "three")
				|| (four.source != ""
					&& (getanddostuff.removeFilenameFromPath(four.source) !== getanddostuff.removeFilenameFromPath(_source))
					&& currentone == "four"))
				newImageSoFadeItIn = true

		// No transition
		if(((slideshowRunning && settings.slideShowTransition === 0) || (!slideshowRunning && settings.transition === 0)) && !newImageSoFadeItIn) {

			// Use 'three' (animated image)
			if(animated && currentone != "three" && currentone != "four") {
				one.opacity = 0
				two.opacity = 0
				three.opacity = 1
				three.visible = true;
				four.opacity = 0
				three.source = _source
				currentone = "three"
			// Use 'one' (not animated image)
			} else if(!animated && currentone != "one" && currentone != "two") {
				one.opacity = 1
				one.visible = true;
				two.opacity = 0
				three.opacity = 0
				four.opacity = 0
				one.source = _source
				currentone = "one"
			// Keep same image element (ONCE PAST HERE WE CAN STICK TO THE SAME IMAGE ELEMENT)
			} else if(currentone == "one") {
				one.opacity = 1
				one.visible = true;
				two.opacity = 0
				three.opacity = 0
				four.opacity = 0
				one.source = _source
			} else if(currentone == "two") {
				one.opacity = 0
				two.opacity = 1
				two.visible = true;
				three.opacity = 0
				four.opacity = 0
				two.source = _source
			} else if(currentone == "three") {
				one.opacity = 0
				two.opacity = 0
				three.opacity = 1
				three.visible = true;
				four.opacity = 0
				three.source = _source
			} else if(currentone == "four") {
				one.opacity = 0
				two.opacity = 0
				three.opacity = 0
				four.opacity = 1
				four.visible = true;
				four.source = _source
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
			three_fadein.duration = duration
			three_fadeout.duration = duration
			four_fadein.duration = duration
			four_fadeout.duration = duration

			if(currentone == "one") {

				if(animated) {

					one.opacity = 1
					three.opacity = 0
					three.scale = 1
					three.visible = true
					three.source = ""
					three.source = _source
					three_fadein.start()
					one_fadeout.start()
					currentone = "three"

				} else {

					one.opacity = 1
					two.opacity = 0
					two.scale = 1
					two.visible = true
					two.source = ""
					two.source = _source
					two_fadein.start()
					one_fadeout.start()
					currentone = "two"

				}

			} else if(currentone == "two") {

				if(animated) {

					two.opacity = 1
					three.opacity = 0
					three.scale = 1
					three.visible = true
					three.source = ""
					three.source = _source
					three_fadein.start()
					two_fadeout.start()
					currentone = "three"

				} else {

					two.opacity = 1
					one.opacity = 0
					one.scale = 1
					one.visible = true
					one.source = ""
					one.source = _source
					one_fadein.start()
					two_fadeout.start()
					currentone = "one"

				}
			} else if(currentone == "three") {

				if(animated) {

					three.opacity = 1
					four.opacity = 0
					four.scale = 1
					four.visible = true
					four.source = ""
					four.source = _source
					four_fadein.start()
					three_fadeout.start()
					currentone = "four"

				} else {

					three.opacity = 1
					one.opacity = 0
					one.scale = 1
					one.visible = true
					one.source = ""
					one.source = _source
					one_fadein.start()
					three_fadeout.start()
					currentone = "one"

				}
			} else if(currentone == "four") {

				if(animated) {

					four.opacity = 1
					three.opacity = 0
					three.scale = 1
					three.visible = true
					three.source = ""
					three.source = _source
					three_fadein.start()
					four_fadeout.start()
					currentone = "three"

				} else {

					four.opacity = 1
					one.opacity = 0
					one.scale = 1
					one.visible = true
					one.source = ""
					one.source = _source
					one_fadein.start()
					four_fadeout.start()
					currentone = "one"

				}
			}

		}
	}

	onSourceSizeChanged: {
		if(one.opacity != 0)
			one.sourceSize = sourceSize
		if(two.opacity != 0)
			two.sourceSize = sourceSize
		if(three.opacity != 0) {
			three.sourceSize.width = sourceSize.width
			three.sourceSize.height = sourceSize.height
		}
		if(four.opacity != 0) {
			four.sourceSize.width = sourceSize.width
			four.sourceSize.height = sourceSize.height
		}
	}

	function forceSourceSizeToBoth(s) {
		one.sourceSize = s
		two.sourceSize = s
		three.sourceSize.width = s.width
		three.sourceSize.height = s.height
		four.sourceSize.width = s.width
		four.sourceSize.height = s.height
	}

	signal statusChanged(var status)

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: one

		x: (Math.max(one.width,two.width,three.width,four.width)-width)/2
		y: (Math.max(one.height,two.height,three.height,four.height)-height)/2

		opacity: 1
		mipmap: true

		mirror: parent.mirror

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	Image {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: two

		x: (Math.max(one.width,two.width,three.width,four.width)-width)/2
		y: (Math.max(one.height,two.height,three.height,four.height)-height)/2

		opacity: 1
		mipmap: true

		mirror: parent.mirror

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	AnimatedImage {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: three

		x: (Math.max(one.width,two.width,three.width,four.width)-width)/2
		y: (Math.max(one.height,two.height,three.height,four.height)-height)/2

		opacity: 1
		mipmap: true

		mirror: parent.mirror

		onStatusChanged: {
			parent.statusChanged(status)
		}

	}

	AnimatedImage {

		asynchronous: parent.asynchronous
		fillMode: parent.fillMode

		id: four

		x: (Math.max(one.width,two.width,three.width,four.width)-width)/2
		y: (Math.max(one.height,two.height,three.height,four.height)-height)/2

		opacity: 1
		mipmap: true

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
		id: three_fadein
		target: three
		properties: "opacity"
		from: 0
		to: 1
		duration: 300
	}
	PropertyAnimation {
		id: four_fadein
		target: four
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
		onStopped: {
			if(resetSourceToEmptyAfterFadeOut) one.source = ""
			one.visible = false
		}
	}
	PropertyAnimation {
		id: two_fadeout
		target: two
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: {
			if(resetSourceToEmptyAfterFadeOut) two.source = ""
			two.visible = false
		}
	}
	PropertyAnimation {
		id: three_fadeout
		target: three
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: {
			if(resetSourceToEmptyAfterFadeOut) three.source = ""
			three.visible = false
		}
	}
	PropertyAnimation {
		id: four_fadeout
		target: four
		properties: "opacity"
		from: 1
		to: 0
		duration: 300
		onStopped: {
			if(resetSourceToEmptyAfterFadeOut) four.source = ""
			four.visible = false
		}
	}

	function resetZoom(loadNewImage) {

		if(loadNewImage !== undefined && loadNewImage === true && ((slideshowRunning && settings.slideShowTransition != 0) || settings.transition != 0)) {
			if(currentone == "one") {
				one.scale = scale
				scale = 1
				if(settings.fitInWindow) norm.scale = Math.min(parent.width / one.width, parent.height / one.height);
			} else if(currentone == "two") {
				two.scale = scale
				scale = 1
				if(settings.fitInWindow) norm.scale = Math.min(parent.width / two.width, parent.height / two.height);
			} else if(currentone == "three") {
				three.scale = scale
				scale = 1
				if(settings.fitInWindow) norm.scale = Math.min(parent.width / three.width, parent.height / three.height);
			} else if(currentone == "four") {
				four.scale = scale
				scale = 1
				if(settings.fitInWindow) norm.scale = Math.min(parent.width / four.width, parent.height / four.height);
			}
		} else {
			one.scale = 1
			two.scale = 1
			three.scale = 1
			four.scale = 1
			scale = 1
			if(settings.fitInWindow) {
				if(currentone == "one") norm.scale = Math.min(parent.width / one.width, parent.height / one.height);
				else if(currentone == "two") norm.scale = Math.min(parent.width / two.width, parent.height / two.height);
				else if(currentone == "three") norm.scale = Math.min(parent.width / three.width, parent.height / three.height);
				else if(currentone == "four") norm.scale = Math.min(parent.width / four.width, parent.height / four.height);
			}
		}

	}

}
