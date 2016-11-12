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

	property int _fadeDurationNextImage: fadeduration

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
					var s = getCurrentSource()
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

					id: loading_rect

					color: "transparent"
					anchors.fill: parent

					// The two image items. 'name' has to match the id
					ImageItem { id: one; name: "one" }
					ImageItem { id: two; name: "two" }
					ImageItem { id: three; name: "three" }
					ImageItem { id: four; name: "four" }

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
		three.stopAnimation()
		four.stopAnimation()

		// if the function was called without an angle, we set it to 0
		if(angle == undefined)
			angle = 0;

		if(angle != imgrect._rotation)
			imgrect._rotation = angle

		// Add on angle to filename
		filename += "::photoqt::" + angle

		// this value is checked later, if a source was set to the same item before but has been modified, we reload it from scratch again
		var mod = getanddostuff.getLastModified(filename)

		filename += "::photoqtmod::" + mod

		// check if image is animated
		var animated = getanddostuff.isImageAnimated(filename)

		// if it is, make filename of current frame unique (forcec reload) and get metadata about animation ([framecount, interval])
		if(animated) {
			filename += "::photoqtani::0"
			var anidat = getanddostuff.getNumFramesAndDuration(filename)
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
				two.source = filename
			}
		// If 'two' is visible...
		} else if(two.opacity != 0) {
			// If it's the exact same file as 'one' showed before, simply make it visible again
			if(three.source == filename)
				makeImageVisible("three")
			else {
				// we set whether image is animated or not
				if(animated)
					three.setAnimated(anidat[0], anidat[1])
				else
					three.setAnimated(1,0)
				// set filename
				three.source = filename
			}
		// If 'three' is visible...
		} else if(three.opacity != 0) {
			// If it's the exact same file as 'one' showed before, simply make it visible again
			if(four.source == filename)
				makeImageVisible("four")
			else {
				// we set whether image is animated or not
				if(animated)
					four.setAnimated(anidat[0], anidat[1])
				else
					four.setAnimated(1,0)
				// set filename
				four.source = filename
			}
		// If 'four' is visible...
		} else if(four.opacity != 0) {
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

		mainview.imageLoading = false

		if(imgid === "one") {
			one.opacity = 1
			two.opacity = 0
			three.opacity = 0
			four.opacity = 0
		} else if(imgid === "two") {
			one.opacity = 0
			two.opacity = 1
			three.opacity = 0
			four.opacity = 0
		} else if(imgid === "three") {
			one.opacity = 0
			two.opacity = 0
			three.opacity = 1
			four.opacity = 0
		} else if(imgid === "four") {
			one.opacity = 0
			two.opacity = 0
			three.opacity = 0
			four.opacity = 1
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

		if(three.sourceSize.width < imgrect.width && three.sourceSize.height < imgrect.height && !fitInWindow)
			three.fillMode = Image.Pad
		else
			three.fillMode = Image.PreserveAspectFit

		if(four.sourceSize.width < imgrect.width && four.sourceSize.height < imgrect.height && !fitInWindow)
			four.fillMode = Image.Pad
		else
			four.fillMode = Image.PreserveAspectFit

	}

	////////////////////////////
	////////////////////////////
	//// ROTATION

	// Rotate image to the left
	function rotateLeft() {
		_fadeDurationNextImage = 200
		if(imgrect._vertically_mirrored)
			imgrect._rotation += 90
		else
			imgrect._rotation -= 90
	}
	// Rotate image to the right
	function rotateRight() {
		_fadeDurationNextImage = 200
		if(imgrect._vertically_mirrored)
			imgrect._rotation -= 90
		else
			imgrect._rotation += 90
	}
	// Rotate image by 180 degrees
	function rotate180() {
		_fadeDurationNextImage = 200
		imgrect._rotation += 180
	}

	// Reset rotation value to zero
	function resetRotation() {
		_fadeDurationNextImage = 200
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
		three.mirror = !three.mirror
		four.mirror = !four.mirror
	}

	function mirrorVertical() {
		imgrect._vertically_mirrored = !imgrect._vertically_mirrored

		one.rotation += 90
		two.rotation += 90
		three.rotation += 90
		four.rotation += 90
		mirrorHorizontal()
		one.rotation += 90
		two.rotation += 90
		three.rotation += 90
		four.rotation += 90
	}

	function resetMirror() {
		if(imgrect._vertically_mirrored) {
			one.rotation = 0
			two.rotation = 0
			three.rotation = 0
			four.rotation = 0
		}
		one.mirror = false
		two.mirror = false
		three.mirror = false
		four.mirror = false
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
		else if(three.opacity != 0)
			return three.sourceSize
		else if(four.opacity != 0)
			return four.sourceSize
		return Qt.size(0,0)
	}

	// get the source filename of the currently displayed image
	function getCurrentSource() {
		if(one.opacity != 0)
			return one.source+""
		else if(two.opacity != 0)
			return two.source+""
		else if(three.opacity != 0)
			return three.source+""
		else if(four.opacity != 0)
			return four.source+""
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
		} else if(three.opacity != 0) {
			contx = (three.width-three.paintedWidth)/2
			conty = (three.height-three.paintedHeight)/2
			mapped = three.mapFromItem(toplevel,pos.x,pos.y)
			return (contx <= mapped.x && contx+three.paintedWidth >= mapped.x && conty <= mapped.y && conty+three.paintedHeight >= mapped.y)
		} else if(four.opacity != 0) {
			contx = (four.width-four.paintedWidth)/2
			conty = (four.height-four.paintedHeight)/2
			mapped = four.mapFromItem(toplevel,pos.x,pos.y)
			return (contx <= mapped.x && contx+four.paintedWidth >= mapped.x && conty <= mapped.y && conty+four.paintedHeight >= mapped.y)
		}
	}

}
