import QtQuick 2.3
import QtQuick.Controls 1.3

Rectangle {

	id: rect_top

	color: "transparent"

	anchors.fill: parent

	// a few properties that can be adjusted by the user
	property bool fitInWindow: false
	property bool interpolationNearestNeighbourUpscale: false
	property int interpolationNearestNeighbourThreshold: 200
	property int fadeduration: 100
	property int zoomduration: 100

	// this one is used internally to distinguish zoom by keys and mouse
	property bool zoomTowardsCenter: true

	clip: true

	// we update the fill mode of the image when the element size has changed
	onWidthChanged: checkFillMode()
	onHeightChanged: checkFillMode()

	Rectangle {

		// a rectangle holding the flickarea. We have an 'outer' rectangle so that we can center the flickable in it for images smaller than its dimensions.
		anchors.fill: parent

		color: "transparent"

		Flickable {

			id: flick

			// dimensions depend on either parent or content
			width: Math.min(parent.width, flick.contentWidth)
			height: Math.min(parent.height, flick.contentHeight)

			// center anchors
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter

			// adjust content dimensions
			contentWidth: imgrect.width*imgrect.scale
			contentHeight: imgrect.height*imgrect.scale

			// when content dimensions changed, adjust x/y of the flickarea
			onContentWidthChanged:
				adjustXY()
			onContentHeightChanged:
				adjustXY()

			// adjust x/y of the flickarea
			function adjustXY() {
				if(contentWidth <= flick.width)
					flick.x = (flick.width-contentWidth)/2
				else
					flick.x = 0
				if(contentHeight <= flick.height)
					flick.y = (flick.height-contentHeight)/2
				else
					flick.y = 0
			}

			// another rectangle holding a rectangle holding the two Image instances. This instance is the one that is zoomed and rotated.
			Rectangle {

				id: imgrect
				color: "transparent"

				// fix dimensions to outermost element dimensions
				width: rect_top.width
				height: rect_top.height

				// center anchors
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter

				// stores whether element is vertically mirrored. This is needed, as there is no way to otherwise detect this
				property bool _vertically_mirrored: false

				// rotation variable, used to load rotated image if requested. DO NOT CONFUSE WITH 'rotation'!
				property int _rotation: 0
				on_RotationChanged: {
					// which angle?
					var angle = _rotation%360;
					var s = "";
					if(one.opacity != 0)
						s = one.source + ""
					else if(two.opacity != 0)
						s = two.source + ""
					var path = s.split("::photoqt")[0]
					// load image rotated
					loadImage(path, angle)
				}

				// Handle scrolling, keep x/y of content as wanted
				property real prevScale: 1
				onScaleChanged: {
					var xoff, yoff

					var x_ratio = (zoomTowardsCenter ? flick.width/2 : localcursorpos.x);
					var y_ratio = (zoomTowardsCenter ? flick.height/2 : localcursorpos.y);
					var w = imgrect.width*imgrect.scale
					var h = imgrect.height*imgrect.scale

					if((w > flick.width || h > flick.height)) {
						if (w > flick.width) {
							xoff = (x_ratio + flick.contentX) * scale / prevScale;
							flick.contentX = xoff - x_ratio;
						}
						if (h > flick.height) {
							yoff = (y_ratio + flick.contentY) * scale / prevScale;
							flick.contentY = yoff - y_ratio;
						}
					}

					prevScale = scale
				}

				// scaling is happening smoothly
				Behavior on scale { NumberAnimation { duration: zoomduration; } }

				// Inside rectangle holding the two Image instances
				Rectangle {

					color: "transparent"
					anchors.fill: parent

					// First image instance
					Image {

						id: one

						// size is same as parent rectangle
						anchors.fill: parent

						// some settings
						cache: false
						mipmap: true
						fillMode: Image.PreserveAspectFit
						asynchronous: true

						// smooth opacity handling
						opacity: 1
						Behavior on opacity { NumberAnimation { duration: fadeduration; } }

						// no source at start
						source: ""

						// the status has changed, show image and start/stop some timers
						onStatusChanged: {
							if(status == Image.Ready) {
								makeImageVisible("one")
								// if it's an animation, start the animation timer
								if(_numFrames > 1 && !one_ani_timer.running)
									one_ani_timer.start()
								// if it's not an animation, make sure the animation timer is stopped, but the masking timer is started
								else if(_numFrames == 1) {
									one_ani_timer.stop()
									one_mask_timer.start()
								}
							}
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

					// second image instance
					Image {

						id: two

						// size is same as parent rectangle
						anchors.fill: parent

						// some settings
						cache: false
						mipmap: true
						fillMode: Image.PreserveAspectFit
						asynchronous: true

						// smooth opacity handling
						opacity: 0
						Behavior on opacity { NumberAnimation { duration: fadeduration; } }

						// no source at start
						source: ""

						// the status has changed, show image and start/stop some timers
						onStatusChanged: {
							if(status == Image.Ready) {
								makeImageVisible("two")
								// if it's an animation, start the animation timer
								if(_numFrames > 1)
									two_ani_timer.start()
								// if it's not an animation, make sure the animation timer is stopped, but the masking timer is started
								else {
									two_ani_timer.stop()
									two_mask_timer.start()
								}
							}
						}
						// animation properties
						property int _numFrames: 1
						property int _interval: 0
						function setAnimated(numFrames, interval) {
							_numFrames = numFrames
							_interval = interval
						}
						function stopAnimation() {
							two_ani_timer.stop()
						}

						// After pre-set timeout...
						Timer {
							id: two_ani_timer
							interval: parent._interval
							repeat: true
							running: false
							onTriggered: two.nextFrame()
						}
						// ... load next frame of animated image
						function nextFrame() {
							var s = two.source+""
							var p = s.split("::photoqtani::")
							var next = p[1]*1+1
							if(next >= _numFrames) next = 0;
							two.source = p[0] + "::photoqtani::" + next
						}

						// This element overlays the main Image element and is only visibled if image is not scaled.
						// It shows a scaled-to-screen-size version of the image for better display quality
						Image {
							anchors.fill: parent
							mipmap: parent.mipmap
							cache: parent.cache
							fillMode: parent.fillMode
							opacity: parent.opacity
							asynchronous: false
							// we need to remove image if element is hidden, otherwise there will be an artefact when switching images
							onOpacityChanged: if(opacity == 0) source = ""
							// this line is important, setting the sourceSize
							sourceSize: Qt.size(rect_top.width, rect_top.height)
							visible: imgrect.scale <= 1 && parent._numFrames == 1
							// There is a short delay for showing the masking image, probably not needed...
							Timer {
								id: two_mask_timer
								interval: 200
								repeat: false
								running: false
								onTriggered: parent.source = two.source
							}
						}
					}

					// An overlay image, displaying a 'loading' bar when the image takes a little longer to load
					Rectangle {

						id: loading

						anchors.fill: parent
						color: "#77000000"
						property bool show: false

						opacity: 0
						Behavior on opacity { NumberAnimation { duration: 100 } }

						AnimatedImage {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.verticalCenter: parent.verticalCenter
							fillMode: Image.Pad
							asynchronous: true
							cache: false
							source: "qrc:/img/loading.gif"
							paused: parent.opacity==0
						}
					}
					Timer {
						id: loaderTimer
						interval: 500
						repeat: false
						running: false
						onTriggered: loading.opacity = 1
					}

					function showLoader() {
						if(_image_current_source != "")
							loaderTimer.restart()
					}
					function hideLoader() {
						loaderTimer.stop()
						loading.opacity = 0
					}

				}

			}
		}

	}

	// load a new image at a certain angle
	function loadImage(filename, angle) {

		// stop any possibly started animation
		one.stopAnimation()
		two.stopAnimation()

		// if the function was called without an angle, we set it to 0
		if(angle == undefined)
			angle = 0;

		// Add on angle to filename
		filename += "::photoqt::" + angle

		// check if image is animated
		var animated = getanddostuff.isImageAnimated(filename)

		// if it is, make filename of current frame unique (forcec reload) and get metadata about animation ([framecount, interval])
		if(animated) {
			filename += "::photoqtani::0"
			var anidat = getanddostuff.getNumFramesAndDuration(filename)
		}

		// if directory was reloaded, we ensure that the current image is reset properly
		if(directoryFileReloaded) {
			one.source = "qrc:/img/empty.png"
			two.source = "qrc:/img/empty.png"
			directoryFileReloaded = false
		}

		// If 'one' is visible...
		if(one.opacity != 0) {
			// If it's the exact same file as 'two' showed before, simply make it visible again
			if(two.source == filename)
				makeImageVisible("two")
			else {
				// we set whether image is animated or not
				if(animated)
					two.setAnimated(anidat[0], anidat[1])
				else
					two.setAnimated(1,0)
				// set filename
				two.source = filename;
			}
		// If 'two' is visible...
		} else if(two.opacity != 0) {
			// If it's the exact same file as 'one' showed before, simply make it visible again
			if(one.source == filename)
				makeImageVisible("one")
			else {
				// we set whether image is animated or not
				if(animated)
					one.setAnimated(anidat[0], anidat[1])
				else
					one.setAnimated(1,0)
				// set filename
				one.source = filename
			}
		}

	}

	// make image element visible
	function makeImageVisible(imgid) {

		if(imgid === "one") {
			one.opacity = 1
			two.opacity = 0
		} else if(imgid === "two") {
			one.opacity = 0
			two.opacity = 1
		}

		// update fillmode
		checkFillMode()

	}

	// update fillmode
	function checkFillMode() {

		// don't touch fillmode when image is scaled in
		if(imgrect.scale > 1) return

		if(one.sourceSize.width < imgrect.width && one.sourceSize.height < imgrect.height && !fitInWindow)
			one.fillMode = Image.Pad
		else
			one.fillMode = Image.PreserveAspectFit

		if(two.sourceSize.width < imgrect.width && two.sourceSize.height < imgrect.height && !fitInWindow)
			two.fillMode = Image.Pad
		else
			two.fillMode = Image.PreserveAspectFit

	}

	////////////////////////////
	////////////////////////////
	//// ROTATION

	// Rotate image to the left
	function rotateLeft() {
		imgrect._rotation -= 90
	}
	// Rotate image to the right
	function rotateRight() {
		imgrect._rotation += 90
	}
	// Rotate image by 180 degrees
	function rotate180() {
		imgrect._rotation += 180
	}

	// Reset rotation value to zero
	function resetRotation() {
		imgrect._rotation = 0
	}

	////////////////////////////
	////////////////////////////
	//// ZOOM

	function zoomIn(towardsCenter) {
		if(towardsCenter == undefined) towardsCenter = true
		zoomTowardsCenter = towardsCenter
		imgrect.scale += (imgrect.scale < 1 ? Math.min(0.5,imgrect.scale/2) : Math.max(0.5,imgrect.scale/2))
	}
	function zoomOut(towardsCenter) {
		if(towardsCenter == undefined) towardsCenter = true
		zoomTowardsCenter = towardsCenter
		imgrect.scale -= (imgrect.scale < 1 ? Math.min(0.5,imgrect.scale/2) : Math.max(0.5,imgrect.scale/2))
	}
	function zoomActual() {
		var s = getCurrentSourceSize();
		if(s.width > rect_top.width || s.height > rect_top.height)
			imgrect.scale = Math.max(s.width/rect_top.width,s.height/rect_top.height)
	}
	// Zoom to 250%
	function zoom250() {
		zoomTowardsCenter = true
		imgrect.scale = 2.5
	}
	// Zoom to 500%
	function zoom500() {
		zoomTowardsCenter = true
		imgrect.scale = 5
	}
	// Zoom to 1000%
	function zoom1000() {
		zoomTowardsCenter = true
		imgrect.scale = 10
	}
	function resetZoom() {
		imgrect.scale = 1
	}

	////////////////////////////
	////////////////////////////
	//// MIRROR/FLIP

	function mirrorHorizontal() {
		one.mirror = !one.mirror
		two.mirror = !two.mirror
	}

	function mirrorVertical() {
		imgrect._vertically_mirrored = !imgrect._vertically_mirrored

		one.rotation += 90
		two.rotation += 90
		mirrorHorizontal()
		one.rotation += 90
		two.rotation += 90
	}

	function resetMirror() {
		if(imgrect._vertically_mirrored) {
			one.rotation = 0
			two.rotation = 0
		}
		one.mirror = false
		two.mirror = false
		imgrect._vertically_mirrored = false
	}

	////////////////////////////
	////////////////////////////
	////////////////////////////
	////////////////////////////


	// get the sourcesize of the currently displayed image
	function getCurrentSourceSize() {
		if(one.opacity != 0)
			return one.sourceSize
		else if(two.opacity != 0)
			return two.sourceSize
		return Qt.size(0,0)
	}

	// get the source filename of the currently displayed image
	function getCurrentSource() {
		if(one.opacity != 0)
			return one.source
		else if(two.opacity != 0)
			return two.source
		return ""
	}

	// update interactive mode (disabled, e.g., when touch event is detected)
	function setInteractiveMode(enabled) {
		flick.interactive = enabled
	}

	// check if a click is inside the painted area of the image
	function clickInsideImage(pos) {
		var contx, conty, mapped
		if(one.opacity != 0) {
			contx = (one.width-one.paintedWidth)/2
			conty = (one.height-one.paintedHeight)/2
			mapped = one.mapFromItem(toplevel,pos.x,pos.y)
			return (contx <= mapped.x && contx+one.paintedWidth >= mapped.x && conty <= mapped.y && conty+one.paintedHeight >= mapped.y)
		} else if(two.opacity != 0) {
			contx = (two.width-two.paintedWidth)/2
			conty = (two.height-two.paintedHeight)/2
			mapped = two.mapFromItem(toplevel,pos.x,pos.y)
			return (contx <= mapped.x && contx+two.paintedWidth >= mapped.x && conty <= mapped.y && conty+two.paintedHeight >= mapped.y)
		}
	}

}
