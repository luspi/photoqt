import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

	id: smartimage_top

	color: "#00000000"
	anchors.fill: parent

	// These properties can change the zoom and fade behaviour
	property int fadeduration: 400
	property double zoomduration: 150
	property double zoomstep: 0.3
	property bool fitinwindow: false
	property bool enableanimations: false

	property string _image_currently_in_use: "one"
	property bool _zoomTowardsCenter: false
	property bool _vertical_mirrored: false

	property string _image_current_source: ""

	property bool _zoomSetFromStorage: false
	property var storeContentPos: {"" : [] }
	property var storeZoom: { "": 0 }
	property var storeRotation: { "": 0 }

	// Switch to 'Nearest Neighbour' when size below ...
	property int interpolationNearestNeighbourThreshold: 100
	// Switch to 'Nearest Neighbour' when zoom past its actual size
	property bool interpolationNearestNeighbourUpscale: false

	Flickable {

		id: flickarea

		anchors.fill: parent

		contentWidth: imagecontainer.width
		contentHeight: imagecontainer.height

		onContentXChanged: {
			if(!_zoomSetFromStorage) {
				storeContentPos[_image_current_source] = [flickarea.contentX, flickarea.contentY]
				storeZoom[_image_current_source] = image.scale
			}
		}
		onContentYChanged: {
			if(!_zoomSetFromStorage) {
				storeContentPos[_image_current_source] = [flickarea.contentX, flickarea.contentY]
				storeZoom[_image_current_source] = image.scale
			}
		}

		Rectangle {

			id: imagecontainer

			color: "#00000000"

			width: Math.abs(image.forrotation%180) == 90 ? image.height*image.scale : image.width*image.scale
			height: Math.abs(image.forrotation%180) == 90 ? image.width*image.scale : image.height*image.scale

			onWidthChanged:
				adjustXY()
			onHeightChanged:
				adjustXY()

			function adjustXY() {
				if(width <= flickarea.width)
					x = (flickarea.width-width)/2
				else
					x = 0
				if(height <= flickarea.height)
					y = (flickarea.height-height)/2
				else
					y = 0
			}

			Rectangle {

				id: image

				color: "#00000000"

				scale: 1

				width: (_image_currently_in_use == "one" ? one.width*one.scale
							: (_image_currently_in_use == "two" ? two.width*two.scale
									: (_image_currently_in_use == "three" ? three.width*three.scale
											: four.width*four.scale)))
				height: (_image_currently_in_use == "one" ? one.height*one.scale
							: (_image_currently_in_use == "two" ? two.height*two.scale
									: (_image_currently_in_use == "three" ? three.height*three.scale
											: four.height*four.scale)))

				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter

				Behavior on scale { NumberAnimation { id: aniScale; duration: zoomduration } }
				Behavior on rotation { NumberAnimation { id: aniRotate; duration: zoomduration } }

				property real forrotation: 0
				onForrotationChanged: {
					var hor = flickarea.contentWidth/flickarea.contentX
					var ver = flickarea.contentHeight/flickarea.contentY
					rotation = forrotation
					flickarea.contentX = flickarea.contentWidth*ver
					flickarea.contentY = flickarea.contentHeight*hor
					if(image.scale == 1 && (getCurrentSourceSize().width > smartimage_top.width || getCurrentSourceSize().height > smartimage_top.height)) {
						if(Math.abs(forrotation%180) == 90) {
							var w = imagecontainer.width
							if(_image_currently_in_use == "one")
								one.scale = smartimage_top.height/w/* one.height/one.width*/
							else if(_image_currently_in_use == "two")
								two.scale = smartimage_top.height/w/*two.height/two.width*/
							else if(_image_currently_in_use == "three")
								three.scale = smartimage_top.height/w/*three.height/three.width*/
							else if(_image_currently_in_use == "four")
								four.scale = smartimage_top.height/w/*four.height/four.width*/
						} else if(Math.abs(forrotation%180) == 0) {
							if(_image_currently_in_use == "one")
								one.scale = 1
							else if(_image_currently_in_use == "two")
								two.scale = 1
							else if(_image_currently_in_use == "three")
								three.scale = 1
							else if(_image_currently_in_use == "four")
								four.scale = 1
						}
					}
					storeRotation[_image_current_source] = forrotation
				}

				property real prevScale: 1
				onScaleChanged: {

					var xoff, yoff

					var cursorpos = getCursorPos()
					var x_ratio = (_zoomTowardsCenter ? flickarea.width/2 : cursorpos.x);
					var y_ratio = (_zoomTowardsCenter ? flickarea.height/2 : cursorpos.y);
					var w = imagecontainer.width
					var h = imagecontainer.height

					if((w > flickarea.width || h > flickarea.height)) {
						if (w > flickarea.width) {
							xoff = (x_ratio + flickarea.contentX) * scale / prevScale;
							flickarea.contentX = xoff - x_ratio;
						}
						if (h > flickarea.height) {
							yoff = (y_ratio + flickarea.contentY) * scale / prevScale;
							flickarea.contentY = yoff - y_ratio;
						}
					}

					prevScale = scale

					if(_zoomSetFromStorage) {
						flickarea.contentX = storeContentPos[_image_current_source][0]
						flickarea.contentY = storeContentPos[_image_current_source][1]
					} else
						storeZoom[_image_current_source] = scale

				}

				Image {

					id: one

					width: smartimage_top.width
					height: smartimage_top.height

					Connections {
						target: smartimage_top
						onWidthChanged: one.width = smartimage_top.width
						onHeightChanged: one.height = smartimage_top.height
					}

					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter

					asynchronous: true
					cache: false
					opacity: 0

					Behavior on opacity { NumberAnimation { duration: fadeduration } }
					Behavior on scale { SmoothedAnimation { id: aniScaleOne; duration: zoomduration } }

					mipmap: true
					fillMode: Image.PreserveAspectFit

					onStatusChanged: {
						if(status == Image.Ready) {
							if(sourceSize.width > smartimage_top.width || sourceSize.height > smartimage_top.height) {
								var factor = Math.min(smartimage_top.height/sourceSize.height, smartimage_top.width/sourceSize.width)
								width = sourceSize.width*factor
								height = sourceSize.height*factor
							} else {
								width = sourceSize.width
								height = sourceSize.height
							}
							makeImageVisible(1)
							hideLoader()
						} else
							showLoader()
					}

				}
				Image {

					id: two

					width: smartimage_top.width
					height: smartimage_top.height

					Connections {
						target: smartimage_top
						onWidthChanged: two.width = smartimage_top.width
						onHeightChanged: two.height = smartimage_top.height
					}

					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter

					asynchronous: true
					cache: false
					opacity: 0

					Behavior on opacity { NumberAnimation { duration: fadeduration } }
					Behavior on scale { SmoothedAnimation { id: aniScaleTwo; duration: zoomduration } }

					mipmap: true
					fillMode: Image.PreserveAspectFit

					onStatusChanged: {
						if(status == Image.Ready) {
							if(sourceSize.width > smartimage_top.width || sourceSize.height > smartimage_top.height) {
								var factor = Math.min(smartimage_top.height/sourceSize.height, smartimage_top.width/sourceSize.width)
								width = sourceSize.width*factor
								height = sourceSize.height*factor
							} else {
								width = sourceSize.width
								height = sourceSize.height
							}
							makeImageVisible(2)
							hideLoader()
						} else
							showLoader()
					}

				}
				AnimatedImage {

					id: three

					width: smartimage_top.width
					height: smartimage_top.height

					Connections {
						target: smartimage_top
						onWidthChanged: one.width = smartimage_top.width
						onHeightChanged: one.height = smartimage_top.height
					}

					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter

					asynchronous: true
					cache: true
					opacity: 0

					Behavior on opacity { NumberAnimation { duration: fadeduration } }
					Behavior on scale { SmoothedAnimation { id: aniScaleThree; duration: zoomduration } }

					mipmap: true
					fillMode: Image.PreserveAspectFit

					onStatusChanged: {
						if(status == Image.Ready) {
							var sz = getanddostuff.getAnimatedImageSize(three.source)
							var w = sz.width
							var h = sz.height
							if(w > smartimage_top.width || h > smartimage_top.height) {
								var factor = Math.min(smartimage_top.height/h, smartimage_top.width/w)
								width = w*factor
								height = h*factor
							} else {
								width = w
								height = h
							}
							makeImageVisible(3)
							hideLoader()
						} else
							showLoader()
					}

				}
				AnimatedImage {

					id: four

					width: smartimage_top.width
					height: smartimage_top.height

					Connections {
						target: smartimage_top
						onWidthChanged: one.width = smartimage_top.width
						onHeightChanged: one.height = smartimage_top.height
					}

					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter

					asynchronous: true
					cache: true
					opacity: 0

					Behavior on opacity { NumberAnimation { duration: fadeduration } }
					Behavior on scale { SmoothedAnimation { id: aniScaleFour; duration: zoomduration } }

					mipmap: true
					fillMode: Image.PreserveAspectFit

					onStatusChanged: {
						if(status == Image.Ready) {
							var sz = getanddostuff.getAnimatedImageSize(four.source)
							var w = sz.width
							var h = sz.height
							if(w > smartimage_top.width || h > smartimage_top.height) {
								var factor = Math.min(smartimage_top.height/h, smartimage_top.width/w)
								width = w*factor
								height = h*factor
							} else {
								width = w
								height = h
							}
							makeImageVisible(4)
							hideLoader()
						} else
							showLoader()
					}

				}

			}

		}

	}

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

	// Load a new image
	function loadImage(src, animated) {

		if(_image_current_source == src)
			return

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

		if(id == 1) {
			if((one.sourceSize.width < smartimage_top.width && one.sourceSize.height < smartimage_top.height) && !fitinwindow)
				one.fillMode = Image.Pad
			else
				one.fillMode = Image.PreserveAspectFit
			one.opacity = 1
			_image_currently_in_use = "one"
		} else if(id == 2) {
			if((two.sourceSize.width < smartimage_top.width && two.sourceSize.height < smartimage_top.height) && !fitinwindow)
				two.fillMode = Image.Pad
			else
				two.fillMode = Image.PreserveAspectFit
			two.opacity = 1
			_image_currently_in_use = "two"
		} else if(id == 3) {
			var sz = getanddostuff.getAnimatedImageSize(three.source)
			if((sz.width < smartimage_top.width && sz.height < smartimage_top.height) && !fitinwindow)
				three.fillMode = Image.Pad
			else
				three.fillMode = Image.PreserveAspectFit
			three.opacity = 1
			_image_currently_in_use = "three"
		} else if(id == 4) {
			var sz = getanddostuff.getAnimatedImageSize(four.source)
			if((sz.width < smartimage_top.width && sz.height < smartimage_top.height) && !fitinwindow)
				four.fillMode = Image.Pad
			else
				four.fillMode = Image.PreserveAspectFit
			four.opacity = 1
			_image_currently_in_use = "four"
		}

		one.scale = 1
		two.scale = 1
		three.scale = 1
		four.scale = 1

		resetMirror()

		if(_image_current_source in storeZoom && settings.rememberZoom) {
			_zoomSetFromStorage = true
			image.scale = storeZoom[_image_current_source]
			flickarea.contentX = storeContentPos[_image_current_source][0]
			flickarea.contentY = storeContentPos[_image_current_source][1]
		} else
			resetZoom()

		if(_image_current_source in storeRotation && settings.rememberRotation)
			image.forrotation = storeRotation[_image_current_source]
		else
			resetRotation()



		var s = getCurrentSourceSize()
		if((interpolationNearestNeighbourUpscale && (imagecontainer.width > s.width || imagecontainer.height > s.height)) || (s.width < interpolationNearestNeighbourThreshold && s.height < interpolationNearestNeighbourThreshold)) {
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

		var ss = getCurrentSourceSize()

		// We increase the zoomstep the more the image is zoomed in. Otherwise it will seem to get incredibly slow very fast
		var frac = Math.max(flickarea.contentWidth/smartimage_top.width, flickarea.contentHeight/smartimage_top.height)
		if(ss.width < imagecontainer.width && ss.height < imagecontainer.height) {
			if(frac > 2)
				use_zoomstep *= Math.max(1,Math.round(2*frac))
			else if(frac > 1.5)
				use_zoomstep *= Math.max(1,Math.round(1.25*frac))
			else if(frac > 1)
				use_zoomstep *= Math.max(1,Math.round(0.75*frac))
			else if(frac > 0.5)
				use_zoomstep *= Math.max(1,Math.round(0.25*frac))
		} else {
			if(frac > 4)
				use_zoomstep *= Math.max(1,Math.round(2*frac))
			else if(frac > 3)
				use_zoomstep *= Math.max(1,Math.round(1.25*frac))
			else if(frac > 2)
				use_zoomstep *= Math.max(1,Math.round(0.75*frac))
			else if(frac > 1)
				use_zoomstep *= Math.max(1,Math.round(0.25*frac))
		}

		// Very small images are sped up, too!
		if(ss.width < smartimage_top.width/10 && ss.height < smartimage_top.height/10)
			use_zoomstep *= 10*Math.max(image.scale/20,1)
		else if(ss.width < smartimage_top.width/5 && ss.height < smartimage_top.height/5)
			use_zoomstep *= 20*Math.max(image.scale/20,1)

		// Which direction?
		use_zoomstep *= inout

		// Limit minimum zoom level
		if(image.scale < 0.1 && inout === -1)
			return
		else if(image.scale+use_zoomstep < 0.1 && inout === -1)
			use_zoomstep = -(image.scale-0.1)

		image.scale += use_zoomstep

	}

	function resetZoom() {
		_zoomSetFromStorage = false
		image.scale = 1
	}

	function zoomActual() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		image.scale = Math.max(getCurrentSourceSize().width/smartimage_top.width,getCurrentSourceSize().height/smartimage_top.height)
	}

	// Zoom to 250%
	function zoom250() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		image.scale = 2.5
	}

	// Zoom to 500%
	function zoom500() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		image.scale = 5
	}

	// Zoom to 1000%
	function zoom1000() {
		_zoomSetFromStorage = false
		_zoomTowardsCenter = true
		image.scale = 10
	}

	function rotateLeft() {
		image.forrotation -= 90
	}
	function rotateRight() {
		image.forrotation += 90
	}
	function resetRotation() {
		var angle = image.forrotation%360
		if(angle  == 90 || angle == 180)
			image.forrotation -= angle
		else if(angle == 270)
			image.forrotation += 90
	}

	function mirrorHorizontal() {
		if(_image_currently_in_use == "one")
			one.mirror = !one.mirror
		else if(_image_currently_in_use == "two")
			two.mirror = !two.mirror
		else if(_image_currently_in_use == "three")
			three.mirror = !three.mirror
		else if(_image_currently_in_use == "four")
			four.mirror = !four.mirror
	}

	function mirrorVertical() {
		_vertical_mirrored = !_vertical_mirrored
		image.forrotation -= 90
		if(_image_currently_in_use == "one")
			one.mirror = !one.mirror
		else if(_image_currently_in_use == "two")
			two.mirror = !two.mirror
		else if(_image_currently_in_use == "three")
			three.mirror = !three.mirror
		else if(_image_currently_in_use == "four")
			four.mirror = !four.mirror
		image.forrotation -= 90
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

	// Function to get the sourcesize of the current image
	function getCurrentSourceSize() {
		if(_image_currently_in_use == "one")
			return one.sourceSize
		else if(_image_currently_in_use == "two")
			return two.sourceSize
		else if(_image_currently_in_use == "three")
			return getanddostuff.getAnimatedImageSize(three.source)
		else if(_image_currently_in_use == "four")
			return getanddostuff.getAnimatedImageSize(four.source)
		else
			return Qt.size(0,0)
	}

	function setInteractiveMode(enabled) {
		flickarea.interactive = enabled
	}

	function isZoomed() {
		return image.scale!=-1
	}

}
