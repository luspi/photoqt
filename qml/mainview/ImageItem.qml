import QtQuick 2.3

Rectangle {

	id: rect;

	// some general settings
	anchors.fill: parent
	color: "transparent"

	// this will be set to the id in SmartImage.qml
	property string name: ""

	// the source of the image currently set to this item
	property string source: ""
	onSourceChanged: handleNewSource()

	// Simulate the image status property
	property int status: Image.Null
	onStatusChanged: {

		if(source == "") return

		if(status == Image.Ready) {
			makeImageVisible(name)
			// if it's an animation, start the animation timer
			if(_numFrames > 1 && !ani_timer.running)
				ani_timer.start()
			// if it's not an animation, make sure the animation timer is stopped, but the masking timer is started
			else if(_numFrames == 1) {
				ani_timer.stop()
				img_mask.showMaskImage()
			}
			loading_rect.hideLoader()
			lastModified = getanddostuff.getLastModified(source)
		} else
			loading_rect.showLoader()

	}

	// the time the current image was last modified
	property string lastModified: ""

	// if an animation is set, then these store the animation properties
	property int _numFrames: 1
	property int _interval: 0

	// The opacity property
	opacity: 0
	Behavior on opacity { NumberAnimation { duration: _fadeDurationNextImage; } }
	onOpacityChanged: {
		if(opacity == 1) {
			_fadeDurationNextImage = fadeduration
			if(_numFrames > 1 && !ani_timer.running)
				ani_timer.start()
			else if(_numFrames == 1) {
				ani_timer.stop()
				img_mask.showMaskImage()
			}
		} else if(opacity == 0) {
			ani_timer.stop()
			img_mask.hideMaskImage()
		}
	}

	// This is the main image, used most of the time!
	Image {
		id: main_img
		anchors.fill: parent
		cache: false
		mipmap: true
		source: "image://empty/" + rect_top.width + "x" + rect_top.height
		fillMode: Image.PreserveAspectFit
		asynchronous: true
		visible: true
		mirror: false
		onStatusChanged: {
			rect.status = status
			if(status == Image.Ready) {
				main_img.visible = true
				submain_img.visible = false
			}
		}
	}

	// only used when animation present. With each frame, PhotoQt swaps image item back and forth to ensure no flickering
	Image {
		id: submain_img
		anchors.fill: parent
		cache: false
		mipmap: true
		source: "image://empty/" + rect_top.width + "x" + rect_top.height
		fillMode: Image.PreserveAspectFit
		asynchronous: true
		mirror: false
		visible: false
		onStatusChanged: {
			rect.status = status
			if(status == Image.Ready) {
				main_img.visible = false
				submain_img.visible = true
			}
		}
	}

	// Animation: After pre-set timeout...
	Timer {
		id: ani_timer
		interval: parent._interval
		repeat: true
		running: false
		onTriggered: nextFrame()
	}

	// Load next frame
	function nextFrame() {
		var s = (main_img.visible ? main_img.source : submain_img.source)+""
		var p = s.split("::photoqtani::")
		var next = p[1]*1+1
		if(next >= _numFrames) next = 0;
		var recheck = getanddostuff.getNumFramesAndDuration(source);
		_interval = recheck[1];
		verboseMessage("ImageItem::nextFrame()", _interval + " - " + next)
		if(main_img.visible)
			submain_img.source = p[0] + "::photoqtani::" + next
		else
			main_img.source = p[0] + "::photoqtani::" + next
	}

	// set animation properties
	function setAnimated(numFrames, interval) {
		verboseMessage("ImageItem::setAnimated()", numFrames + " - " + interval)
		_numFrames = numFrames
		_interval = interval
		main_img.visible = true
		submain_img.visible = false
	}

	// Stop animation timer
	function stopAnimation() {
		ani_timer.stop()
	}
	// restart animation timer, if animation is present
	function restartAnimation() {
		if(_numFrames > 1 && opacity == 1 && !ani_timer.running)
			ani_timer.start()
	}

	// This item is only displayed if the image is not scaled but biger than the screen.
	// It shows a scaled-to-screen-size version of the image for better display quality.
	Image {
		id: img_mask
		anchors.fill: parent
		mipmap: true
		cache: false
		mirror: false
		asynchronous: true
		fillMode: Image.PreserveAspectFit
		opacity: 1
		// we need to remove image if element is hidden, otherwise there will be an artefact when switching images
		onOpacityChanged: if(opacity == 0) hideMaskImage()
		// this line is important, setting the sourceSize
		sourceSize: Qt.size(rect_top.width, rect_top.height)
		visible: imgrect.scale <= 1 && source != "" && (getSourceSize().width > flick.width || getSourceSize().height > flick.height)
		function showMaskImage() {
			source = parent.source
		}
		function hideMaskImage() {
			source = ""
		}
	}

	// handle new source filename
	function handleNewSource() {
		submain_img.source = ""
		main_img.source = source
	}

	// return the image source size
	function getSourceSize() {
		return main_img.sourceSize
	}

	// set a fillmode to the images here
	function setFillMode(mode) {
		main_img.fillMode = mode
		submain_img.fillMode = mode
		img_mask.fillMode = mode
	}

	// set the mirror property
	function setMirror(mirr) {
		main_img.mirror = mirr
		submain_img.mirror = mirr
		img_mask.mirror = mirr
	}

	// get the mirror property (same on all three elements)
	function getMirror() {
		return main_img.mirror
	}

	// get the dimensions of the image actually displayed
	function getActualPaintedImageSize() {
		return Qt.size(main_img.paintedWidth, main_img.paintedHeight)
	}

	//////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////
	//
	// When an element is shown on top of the mainview, we interrupt an animation while they are visible
	//

	Connections {
		target: openfile
		onOpacityChanged: {
			if(openfile.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: settingsmanager
		onOpacityChanged: {
			if(settingsmanager.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: about
		onOpacityChanged: {
			if(about.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: wallpaper
		onOpacityChanged: {
			if(wallpaper.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: scaleImage
		onOpacityChanged: {
			if(scaleImage.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: filter
		onOpacityChanged: {
			if(filter.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: rename
		onOpacityChanged: {
			if(rename.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: slideshow
		onOpacityChanged: {
			if(slideshow.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}
	Connections {
		target: startup
		onOpacityChanged: {
			if(startup.opacity >= 0.5) stopAnimation()
			else restartAnimation()
		}
	}

}
