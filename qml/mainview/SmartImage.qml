import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	id: smartimage_top

	// Invisible background
	color: "#00000000"

	anchors.fill: parent

	// These properties can change the zoom and fade behaviour
	property int fadeduration: 400
	property double zoomduration: 150
	property double zoomstep: 0.3
	property bool fitinwindow: false
	property bool enableanimations: true

	// Switch to 'Nearest Neighbour' when size below ...
	property int interpolationNearestNeighbourThreshold: 100
	// Switch to 'Nearest Neighbour' when zoom past its actual size
	property bool interpolationNearestNeighbourUpscale: false

	// Hide everything outside of rectangle
	clip: true

	// Current image item in use
	property string _image_currently_in_use: "one"
	property string _image_current_source: ""
	// Mirrored property
	property bool _vertical_mirrored: false
	// Zoom to where
	property bool _zoomTowardsCenter: false
	property bool _zoomSetFromStorage: false
	property var _zoomSetFromStorageContentPos: []
	property bool _rotationSetFromStorage: false
	property int _rotaniToSet: 0

	property var storeZoom: { "":[] }
	property var storeRotation: { "":0 }

	Flickable {

		id: flickarea
		anchors.fill: parent

		// Re-calculate size
		property real prevScale
		function calculateSize() {
			if(fitinwindow && _getCurrentlyDisplayedImageSize().width > 0 && _getCurrentlyDisplayedImageSize().height > 0)
				manip.scale = Math.min(flickarea.width / _getCurrentlyDisplayedImageSize().width, flickarea.height / _getCurrentlyDisplayedImageSize().height);
			prevScale = Math.min(manip.scale, 1);
		}

		// Set content size -> if not done, no scrolling possible
		contentHeight: Math.max((getCurrentOrientation() == 90 ? _getCurrentlyDisplayedImageSize().width : _getCurrentlyDisplayedImageSize().height)*flickarea.contentItem.scale,smartimage_top.height)
		contentWidth: Math.max((getCurrentOrientation() == 90 ? _getCurrentlyDisplayedImageSize().height : _getCurrentlyDisplayedImageSize().width)*flickarea.contentItem.scale,smartimage_top.width)

		onContentXChanged: {
			if(_image_current_source in storeZoom)
				storeZoom[_image_current_source] = [storeZoom[_image_current_source][0],flickarea.contentX, flickarea.contentY]
			else
				storeZoom[_image_current_source] = [1,flickarea.contentX, flickarea.contentY]
		}
		onContentYChanged: {
			if(_image_current_source in storeZoom)
				storeZoom[_image_current_source] = [storeZoom[_image_current_source][0],flickarea.contentX, flickarea.contentY]
			else
				storeZoom[_image_current_source] = [1,flickarea.contentX, flickarea.contentY]
		}

		Behavior on contentItem.scale { NumberAnimation { duration: zoomduration; } }

		// The item used to manipulate the images (scale/rotate)
		Item {

			id: manip
			width: smartimage_top.width
			height: smartimage_top.height

			x: (getCurrentOrientation() == 90) ? Math.max(0,(_getCurrentlyDisplayedImageSize().height-smartimage_top.width)/2) :  Math.max(0,(_getCurrentlyDisplayedImageSize().width-smartimage_top.width)/2)
			y: (getCurrentOrientation() == 90) ? Math.max(0,(_getCurrentlyDisplayedImageSize().width-smartimage_top.height)/2): Math.max(0,(_getCurrentlyDisplayedImageSize().height-smartimage_top.height)/2)

			// Animate rotation
			transform: Rotation {
				id: imgrot;
				origin.x: manip.width/2
				origin.y: manip.height/2
				SmoothedAnimation on angle { id: rotani; duration: (enableanimations ? zoomduration : 1); }
			}

			// Animate scaling - velocity is changed to duration in 'onStatusChanged' below
			// For some reason, setting duration right away here does not work
			Behavior on scale { NumberAnimation { id: scaleani; duration: zoomduration } }

			onScaleChanged: {

				var s = _getCurrentlyDisplayedImageSize()

				var xoff, yoff

				var cursorpos = getCursorPos()
				var x_ratio = (_zoomTowardsCenter ? flickarea.width/2 : cursorpos.x);
				var y_ratio = (_zoomTowardsCenter ? flickarea.height/2 : cursorpos.y);
				var w = s.width
				var h = s.height

				if(getCurrentOrientation() != 90) {

					flickarea.contentHeight = Math.max(flickarea.height, h)
					flickarea.contentWidth = Math.max(flickarea.width,w)

					if(!_zoomSetFromStorage && (w >= manip.width || h >= manip.height)) {
						if (w > manip.width) {
							xoff = (x_ratio + flickarea.contentX) * scale / flickarea.prevScale;
							flickarea.contentX = xoff - x_ratio;
						}
						if (h > manip.height) {
							yoff = (y_ratio + flickarea.contentY) * scale / flickarea.prevScale;
							flickarea.contentY = yoff - y_ratio;
						}
					}

				} else {

					flickarea.contentHeight = Math.max(flickarea.height, w)
					flickarea.contentWidth = Math.max(flickarea.width,h)

					if(!_zoomSetFromStorage && (h >= manip.width || w >= manip.height)) {
						if (h > manip.width) {
							xoff = (x_ratio + flickarea.contentX) * scale / flickarea.prevScale;
							flickarea.contentX = xoff - x_ratio;
						}
						if (w > manip.height) {
							yoff = (y_ratio + flickarea.contentY) * scale / flickarea.prevScale;
							flickarea.contentY = yoff - y_ratio;
						}
					}


				}

				if(_zoomSetFromStorage) {
					flickarea.contentX = _zoomSetFromStorageContentPos[0]
					flickarea.contentY = _zoomSetFromStorageContentPos[1]
				}


				flickarea.prevScale = scale;

				flickarea.returnToBounds()

			}

			Image {

				id: one
				anchors.fill: parent

				asynchronous: true
				opacity: 0

				Behavior on opacity { NumberAnimation { duration: fadeduration } }

				mipmap: true
				fillMode: Image.PreserveAspectFit

				onStatusChanged: {
					if(status == Image.Ready) {
						flickarea.calculateSize();
						makeImageVisible(1)
					}
				}

			}
			Image {

				id: two
				anchors.fill: parent

				asynchronous: true
				opacity: 0

				Behavior on opacity { NumberAnimation { duration: fadeduration } }

				mipmap: true
				fillMode: Image.PreserveAspectFit

				onStatusChanged: {
					if(status == Image.Ready) {
						flickarea.calculateSize();
						makeImageVisible(2)
					}
				}

			}
			AnimatedImage {

				id: three
				anchors.fill: parent

				asynchronous: true
				opacity: 0

				Behavior on opacity { NumberAnimation { duration: fadeduration } }

				mipmap: true
				fillMode: Image.PreserveAspectFit

				onStatusChanged: {
					if(status == Image.Ready) {
						flickarea.calculateSize();
						makeImageVisible(3)
					}
				}

			}
			AnimatedImage {

				id: four
				anchors.fill: parent

				asynchronous: true
				opacity: 0

				Behavior on opacity { NumberAnimation { duration: fadeduration } }

				mipmap: true
				fillMode: Image.PreserveAspectFit

				onStatusChanged: {
					if(status == Image.Ready) {
						flickarea.calculateSize();
						makeImageVisible(4)
					}
				}

			}

		}

	}

	// Load a new image
	function loadImage(src, animated) {

		_image_current_source = src

		// IMPORTANT: For the checks below, we HAVE to use double == and NOT triple!!!

		if(!animated) {

			if(_image_currently_in_use == "one") {
				if(two.source == src)
					makeImageVisible(2)
				else
					two.source = src;
			} else if(_image_currently_in_use == "two") {
				if(one.source == src)
					makeImageVisible(1)
				else
					one.source = src;
			} else if(_image_currently_in_use == "three") {
				if(one.source == src)
					makeImageVisible(1)
				else
					one.source = src;
			} else if(_image_currently_in_use == "four") {
				if(one.source == src)
					makeImageVisible(1)
				else
					one.source = src;
			}

		} else {

			if(_image_currently_in_use == "one") {
				if(three.source == src)
					makeImageVisible(3)
				else
					three.source = src;
			} else if(_image_currently_in_use == "two") {
				if(three.source == src)
					makeImageVisible(3)
				else
					three.source = src;
			} else if(_image_currently_in_use == "three") {
				if(four.source == src)
					makeImageVisible(4)
				else
					four.source = src;
			} else if(_image_currently_in_use == "four") {
				if(three.source == src)
					makeImageVisible(3)
				else
					three.source = src;
			}

		}

	}

	// Once an image finished loading, we make it visible
	function makeImageVisible(id) {

		if(_image_currently_in_use == "one")
			one.opacity = 0
		else if(_image_currently_in_use == "two")
			two.opacity = 0
		else if(_image_currently_in_use == "three")
			three.opacity = 0
		else if(_image_currently_in_use == "four")
			four.opacity = 0

		if(id === 1) {
			if((one.sourceSize.width < smartimage_top.width || one.sourceSize.height < smartimage_top.height) && !fitinwindow)
				one.fillMode = Image.Pad
			else
				one.fillMode = Image.PreserveAspectFit
			one.opacity = 1
			_image_currently_in_use = "one"
		} else if(id === 2) {
			if((two.sourceSize.width < smartimage_top.width || two.sourceSize.height < smartimage_top.height) && !fitinwindow)
				two.fillMode = Image.Pad
			else
				two.fillMode = Image.PreserveAspectFit
			two.opacity = 1
			_image_currently_in_use = "two"
		} else if(id === 3) {
			if((three.sourceSize.width < smartimage_top.width || three.sourceSize.height < smartimage_top.height) && !fitinwindow)
				three.fillMode = Image.Pad
			else
				three.fillMode = Image.PreserveAspectFit
			three.opacity = 1
			_image_currently_in_use = "three"
		} else if(id === 4) {
			if((four.sourceSize.width < smartimage_top.width || four.sourceSize.height < smartimage_top.height) && !fitinwindow)
				four.fillMode = Image.Pad
			else
				four.fillMode = Image.PreserveAspectFit
			four.opacity = 1
			_image_currently_in_use = "four"
		}

		var s = _getCurrentSourceSize()
		var d = _getCurrentlyDisplayedImageSize()
		if((interpolationNearestNeighbourUpscale && (d.width > s.width || d.height > s.height)) || (s.width < interpolationNearestNeighbourThreshold && s.height < interpolationNearestNeighbourThreshold)) {
			if(_image_currently_in_use == "one" && one.smooth == true)
				one.smooth = false
			else if(_image_currently_in_use == "two" && two.smooth == true)
				two.smooth = false
			else if(_image_currently_in_use == "three" && three.smooth == true)
				three.smooth = false
			else if(_image_currently_in_use == "four" && four.smooth == true)
				four.smooth = false
		} else {
			if(_image_currently_in_use == "one" && one.smooth == false)
				one.smooth = true
			else if(_image_currently_in_use == "two" && two.smooth == false)
				two.smooth = true
			else if(_image_currently_in_use == "three" && three.smooth == false)
				three.smooth = true
			else if(_image_currently_in_use == "four" && four.smooth == false)
				four.smooth = true
		}

		if(_image_current_source in storeZoom && settings.rememberZoom) {

			_zoomSetFromStorage = true

			var z = storeZoom[_image_current_source]
			_zoomSetFromStorageContentPos = [z[1],z[2]]
			if(z[0] === 1111111111111) {
				zoomActual()
			} else if(z[0] === 250250250250) {
				zoom250()
			} else if(z[0] === 500500500500) {
				zoom500()
			} else if(z[0] === 1000100010001000) {
				zoom1000()
			} else if(z[0] !== 1) {
				manip.scale = z[0]
			} else
				resetZoom()

		} else
			resetZoom()

		if(_image_current_source in storeRotation && settings.rememberRotation) {

			_rotationSetFromStorage = true

			var r = storeRotation[_image_current_source]%360

			_executeRotation(0)
			_executeRotation(r)

		} else
			resetRotation()

		resetMirror()

	}

	function _getCurrentlyDisplayedImageSize() {

		var factor
		var ss = _getCurrentSourceSize()
		var w = ss.width
		var h = ss.height

		if(ss.width < manip.width && ss.height < manip.height)
			factor = manip.scale*flickarea.contentItem.scale
		else {
			var w_factor = flickarea.width/w
			var h_factor = flickarea.height/h

			if(w_factor >= h_factor) {
				factor = w_factor
				if(h*factor > flickarea.height)
					factor = h_factor
			} else {
				factor = h_factor
				if(w*factor > flickarea.width)
					factor = w_factor
			}

			factor *= manip.scale*flickarea.contentItem.scale

		}

		return Qt.size(w*factor, h*factor)
	}

	// Function to get the sourcesize of the current image
	function _getCurrentSourceSize() {
		if(_image_currently_in_use == "one")
			return one.sourceSize
		else if(_image_currently_in_use == "two")
			return two.sourceSize
		else if(_image_currently_in_use == "three")
			return three.sourceSize
		else if(_image_currently_in_use == "four")
			return four.sourceSize
	}

	// Can be called from outside for zooming
	function zoomIn(towardsCenter) {
		_executeZoom(+1,towardsCenter)
	}
	function zoomOut(towardsCenter) {
		_executeZoom(-1,towardsCenter)
	}

	function _executeZoom(inout, towardsCenter) {

		_zoomSetFromStorage = false

		if(towardsCenter === undefined)
			towardsCenter = false
		_zoomTowardsCenter = towardsCenter

		var use_zoomstep = zoomstep

		var ss = _getCurrentSourceSize()
		var ds = _getCurrentlyDisplayedImageSize()

		// We increase the zoomstep the more the image is zoomed in. Otherwise it will seem to get incredibly slow very fast
		if(ss.width < manip.width && ss.height < manip.height) {
			if(flickarea.contentWidth/smartimage_top.width > 2)
				use_zoomstep *= Math.max(1,Math.round(4*flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 1.5)
				use_zoomstep *= Math.max(1,Math.round(2*flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 1)
				use_zoomstep *= Math.max(1,Math.round(flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 0.5)
				use_zoomstep *= Math.max(1,Math.round(0.5*flickarea.contentWidth/smartimage_top.width))
		} else {
			if(flickarea.contentWidth/smartimage_top.width > 8)
				use_zoomstep *= Math.max(1,Math.round(4*flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 6)
				use_zoomstep *= Math.max(1,Math.round(2*flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 4)
				use_zoomstep *= Math.max(1,Math.round(flickarea.contentWidth/smartimage_top.width))
			else if(flickarea.contentWidth/smartimage_top.width > 2)
				use_zoomstep *= Math.max(1,Math.round(0.5*flickarea.contentWidth/smartimage_top.width))
		}

		// Very small images are sped up, too!
		if(ss.width < smartimage_top.width/10 && ss.height < smartimage_top.height/10)
			use_zoomstep *= 10*Math.max(manip.scale/20,1)
		else if(ss.width < smartimage_top.width/5 && ss.height < smartimage_top.height/5)
			use_zoomstep *= 20*Math.max(manip.scale/20,1)

		// Which direction?
		use_zoomstep *= inout

		// Limit minimum zoom level
		if(manip.scale < 0.1 && inout === -1)
			return
		else if(manip.scale+use_zoomstep < 0.1 && inout === -1)
			use_zoomstep = -(manip.scale-0.1)

		// Limit maximum zoom level
		if(manip.scale > Math.max(manip.width/smartimage_top.width,manip.height/smartimage_top.height)*30
				&& inout === 1 && ds.width > manip.width*2 && ds.height > manip.height*2)
			return;

		manip.scale += use_zoomstep

		if(_image_current_source in storeZoom)
			storeZoom[_image_current_source] = [storeZoom[_image_current_source][0]+use_zoomstep,flickarea.contentX, flickarea.contentY]
		else
			storeZoom[_image_current_source] = [1+use_zoomstep,flickarea.contentX, flickarea.contentY]

	}
	function zoomActual() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		manip.scale = Math.max(_getCurrentSourceSize().width/smartimage_top.width,_getCurrentSourceSize().height/smartimage_top.height)
		storeZoom[_image_current_source] = [111111111111,flickarea.contentX, flickarea.contentY]
	}

	// Zoom to 250%
	function zoom250() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		manip.scale = 2.5
		storeZoom[_image_current_source] = [250250250250,flickarea.contentX, flickarea.contentY]
	}

	// Zoom to 500%
	function zoom500() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		manip.scale = 5
		storeZoom[_image_current_source] = [500500500500,flickarea.contentX, flickarea.contentY]
	}

	// Zoom to 1000%
	function zoom1000() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		manip.scale = 10
		storeZoom[_image_current_source] = [1000100010001000,flickarea.contentX, flickarea.contentY]
	}

	// Reset zoom
	function resetZoom() {
		manip.scale = 1
		storeZoom[_image_current_source] = [1,flickarea.contentX, flickarea.contentY]
		flickarea.returnToBounds()
	}

	// We need to use timers when calling a rotation function again before the animation has finished
	// If we don't, then the scaling adjustment would be all wrong!
	Timer {
		id: callRotateLeft
		running:false
		interval: 50
		onTriggered: rotateLeft()
	}
	function rotateLeft() {
		if(rotani.running) {
			callRotateLeft.restart()
			return
		}
		_executeRotation(imgrot.angle - 90)
	}
	Timer {
		id: callRotateRight
		running:false
		interval: 50
		onTriggered: rotateRight()
	}
	function rotateRight() {
		if(rotani.running) {
			callRotateRight.restart()
			return
		}
		_executeRotation(imgrot.angle + 90)
	}
	Timer {
		id: callRotate180
		running:false
		interval: 50
		onTriggered: rotate180()
	}
	function rotate180() {
		if(rotani.running) {
			callRotate180.restart()
			return
		}
		_executeRotation(imgrot.angle + 180)
	}


	Timer {
		id: callExecRotation
		running:false
		interval: 50
		property int angle: 0
		onTriggered: _executeRotation(angle)
	}
	function _executeRotation(angle) {

		if(rotani.running) {
			callExecRotation.angle = angle
			callExecRotation.restart()
			return
		}

		_rotaniToSet = angle
		rotani.to = angle

		if(!_rotationSetFromStorage)
			storeRotation[_image_current_source] = angle
		_rotationSetFromStorage = false

		rotani.start()
		if(manip.scale == 1) {
			if(Math.abs(angle%180) == 90 && _getCurrentlyDisplayedImageSize().width > smartimage_top.height)
				flickarea.contentItem.scale = smartimage_top.height/_getCurrentlyDisplayedImageSize().width
			else {
				flickarea.contentItem.scale = 1
			}
		}
	}

	function resetRotation() {
		// Not necessary to do anything
		if(imgrot.angle%360 == 0) return

		// Get the right direction
		if(imgrot.angle%360 == 270)
			var rotateto = imgrot.angle+90
		else if(imgrot.angle%360 == -270)
			rotateto = imgrot.angle-90
		else
			rotateto = imgrot.angle-(imgrot.angle%360);

		rotani.to = rotateto
		_rotaniToSet = rotateto
		rotani.start()
		flickarea.contentItem.scale = 1

		storeRotation[_image_current_source] = 0

		var s = _getCurrentlyDisplayedImageSize()
		var w = s.width
		var h = s.height

		if(getCurrentOrientation() == 0) {
			flickarea.contentHeight = Math.max(flickarea.height, h)
			flickarea.contentWidth = Math.max(flickarea.width,w)
		} else {
			flickarea.contentHeight = Math.max(flickarea.height, w)
			flickarea.contentWidth = Math.max(flickarea.width,h)
		}

	}

	function mirrorHorizontal() {
		var m = one.mirror
		one.mirror = !m
		two.mirror = !m
		three.mirror = !m
		four.mirror = !m
	}

	function mirrorVertical() {
		_vertical_mirrored = !_vertical_mirrored
		imgrot.angle -=90
		var m = one.mirror
		one.mirror = !m
		two.mirror = !m
		three.mirror = !m
		four.mirror = !m
		imgrot.angle -=90
	}
	function resetMirror() {
		if(_image_currently_in_use == "one")
			one.mirror = false
		else if(_image_currently_in_use == "two")
			two.mirror = false
		else if(_image_currently_in_use == "three")
			three.mirror = false
		else if(_image_currently_in_use == "four")
			four.mirror = false
		if(_vertical_mirrored) {
			imgrot.angle -= 180
			_vertical_mirrored = false
		}
	}
	function setInteractiveMode(enabled) {
		flickarea.interactive = enabled
	}

	function isZoomed() {
		return manip.scale!=-1
	}

	function getCurrentOrientation() {

		var tmp = rotani.running ? _rotaniToSet : imgrot.angle
		return Math.abs(tmp%180)

	}

}
