import QtQuick 2.3
// First image instance
Image {

	id: img

	property string name: ""

	// size is same as parent rectangle
	anchors.fill: parent

	// some settings
	cache: true
	mipmap: true
	fillMode: Image.PreserveAspectFit
	asynchronous: true

	// smooth opacity handling
	opacity: 1
	Behavior on opacity { NumberAnimation { duration: _fadeDurationNextImage; } }
	onOpacityChanged: {
		if(opacity == 1) {
			_fadeDurationNextImage = fadeduration
			if(_numFrames > 1 && !ani_timer.running)
				ani_timer.start()
			else if(_numFrames == 1) {
				ani_timer.stop()
				mask_timer.start()
			}
		} else if(opacity == 0) {
			preload.source = ""
			ani_timer.stop()
			mask_timer.stop()
		}
	}

	// no source at start
	source: ""
	onSourceChanged: {
		img_mask.source = ""
		preload.source = ""
	}

	// store last modification time in the format 'Hmsz'
	property string lastModified: ""

	// the status has changed, show image and start/stop some timers
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
				mask_timer.start()
			}
			loading_rect.hideLoader()
			lastModified = getanddostuff.getLastModified(source)
		} else
			loading_rect.showLoader()
	}

	// animation properties
	property int _numFrames: 1
	property int _interval: 0
	function setAnimated(numFrames, interval) {
		_numFrames = numFrames
		_interval = interval
	}
	function stopAnimation() {
		ani_timer.stop()
		preload.source = ""
	}
	function restartAnimation() {
		if(_numFrames > 1 && opacity == 1 && !ani_timer.running)
			ani_timer.start()
	}
	// After pre-set timeout...
	Timer {
		id: ani_timer
		interval: parent._interval
		repeat: true
		running: false
		onTriggered: img.nextFrame()
	}
	// ... load next frame of animated image
	function nextFrame() {
		var s = img.source+""
		var p = s.split("::photoqtani::")
		var next = p[1]*1+1
		if(next >= _numFrames) next = 0;
		preload.source = p[0] + "::photoqtani::" + next
	}

	// This element overlays the main Image element and is only visibled if image is not scaled.
	// It shows a scaled-to-screen-size version of the image for better display quality
	Image {
		id: img_mask
		anchors.fill: parent
		mipmap: parent.mipmap
		cache: parent.cache
		opacity: parent.opacity
		mirror: parent.mirror
		asynchronous: false
		fillMode: parent.fillMode
		// we need to remove image if element is hidden, otherwise there will be an artefact when switching images
		onOpacityChanged: if(opacity == 0) source = ""
		// this line is important, setting the sourceSize
		sourceSize: Qt.size(rect_top.width, rect_top.height)
		visible: imgrect.scale <= 1 /*&& parent._numFrames == 1*/
		// There is a short delay for showing the masking image, probably not needed...
		Timer {
			id: mask_timer
			interval: _fadeDurationNextImage
			repeat: false
			running: false
			onTriggered: parent.source = img.source
		}
	}

	Image {
		id: preload
		opacity: 0
		source: ""
		cache: true
		asynchronous: true
		onStatusChanged:
			if(status == Image.Ready && source != "" && parent.opacity != 0) {
				parent.source = source
				source = ""
			}
	}

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
