import QtQuick 2.3
// First image instance
Image {

	id: one

	property string name: ""

	// size is same as parent rectangle
	anchors.fill: parent

	// some settings
	cache: false
	mipmap: true
	fillMode: Image.PreserveAspectFit
	asynchronous: true

	// smooth opacity handling
	opacity: 1
	Behavior on opacity { NumberAnimation { duration: _fadeDurationNextImage; } }
	onOpacityChanged: if(opacity == 1) _fadeDurationNextImage = fadeduration

	// no source at start
	source: ""

	// store last modification time in the format 'Hmsz'
	property string lastModified: ""

	// the status has changed, show image and start/stop some timers
	onStatusChanged: {
		if(status == Image.Ready) {
			makeImageVisible(name)
			// if it's an animation, start the animation timer
			if(_numFrames > 1 && !one_ani_timer.running)
				one_ani_timer.start()
			// if it's not an animation, make sure the animation timer is stopped, but the masking timer is started
			else if(_numFrames == 1) {
				one_ani_timer.stop()
				one_mask_timer.start()
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
		one_ani_timer.stop()
	}
	// After pre-set timeout...
	Timer {
		id: one_ani_timer
		interval: parent._interval
		repeat: true
		running: false
		onTriggered: one.nextFrame()
	}
	// ... load next frame of animated image
	function nextFrame() {
		var s = one.source+""
		var p = s.split("::photoqtani::")
		var next = p[1]*1+1
		if(next >= _numFrames) next = 0;
		one.source = p[0] + "::photoqtani::" + next
	}

	// This element overlays the main Image element and is only visibled if image is not scaled.
	// It shows a scaled-to-screen-size version of the image for better display quality
	Image {
		anchors.fill: parent
		mipmap: parent.mipmap
		cache: parent.cache
		opacity: parent.opacity
		asynchronous: false
		fillMode: parent.fillMode
		// we need to remove image if element is hidden, otherwise there will be an artefact when switching images
		onOpacityChanged: if(opacity == 0) source = ""
		// this line is important, setting the sourceSize
		sourceSize: Qt.size(rect_top.width, rect_top.height)
		visible: imgrect.scale <= 1 && parent._numFrames == 1
		// There is a short delay for showing the masking image, probably not needed...
		Timer {
			id: one_mask_timer
			interval: 200
			repeat: false
			running: false
			onTriggered: parent.source = one.source
		}
	}
}
