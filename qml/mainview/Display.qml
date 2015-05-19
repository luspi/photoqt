import QtQuick 2.3
import QtQuick.Controls.Styles 1.2
import QtQuick.Controls 1.2

import "../elements"

Item {

	id: item

	// Position item
	x: 0
	y: 0
	width: background.width
	height: (settings.thumbnailKeepVisible ? background.height-thumbnailBar.height+thumbnailbarheight_addon/2 : background.height)

	// How fast do we zoom in/out
	property real scaleSpeed: 0.1

	// Keep track of where we are in zooming
	property bool zoomTowardsCenter: false

	// Some image stuff
	property bool imageWidthLargerThanHeight: true
	property size imageSize: Qt.size(0,0)
	property bool fullsizeImageLoaded: false
	function isFullsizeImageLoaded() { return fullsizeImageLoaded; }

	// Set image
	function setImage(path, animated) {

		// Hide 'nothing loaded' message
		nofileloaded.visible = false

		// Load scaled down version by default
		fullsizeImageLoaded = false

		// Reset changes
		resetZoom(true)
		resetRotation()

		// Set animation
		norm.animated = animated

		// Set source
		norm.source = path

		// Pad or Fit?
		imageSize = getanddostuff.getImageSize(path)
		if(imageSize.width < item.width && imageSize.height < item.height)
			norm.fillMode = Image.Pad
		else
			norm.fillMode = Image.PreserveAspectFit

		imageWidthLargerThanHeight = (imageSize.width >= imageSize.height);

		// Update metadata
		metaData.setData(getmetadata.getExiv2(path))

	}

	// Update source sizes
	function setSourceSize(w,h) {
		norm.forceSourceSizeToBoth(Qt.size(w,h))
	}

	function resetZoom(loadNewImage) {

		fullsizeImageLoaded = false

		// Re-set source size to screen size
		if(norm.rotation%180 == 90 && imageWidthLargerThanHeight)
			setSourceSize(item.height,item.width)
		else
			setSourceSize(item.width,item.height)

		// Reset scaling
		norm.resetZoom(loadNewImage)

	}

	function resetRotation() {
		norm.rotation = 0
		norm.mirror = false
		fullsizeImageLoaded = false
		setSourceSize(item.width,item.height)
	}

	function zoomIn(towardsCenter) {
		zoomTowardsCenter = (towardsCenter !== undefined ? towardsCenter : false)
		doZoom(true)
	}
	function zoomOut(towardsCenter) {
		zoomTowardsCenter = (towardsCenter !== undefined ? towardsCenter : false)
		doZoom(false)
	}

	function rotateRight() {
		norm.rotation += 90
		norm.calculateSize()
		if(Math.abs(norm.rotation%180) == 90)
			setSourceSize(item.height,item.width)
		else
			setSourceSize(item.width,item.height)
	}

	function rotateLeft() {
		norm.rotation -= 90
		norm.calculateSize()
		if(Math.abs(norm.rotation%180) == 90)
			setSourceSize(item.height,item.width)
		else
			setSourceSize(item.width,item.height)
	}

	function flipHorizontal() {
		norm.mirror = !norm.mirror
		norm.calculateSize()
	}

	function flipVertical() {
		norm.rotation += 90
		norm.mirror = !norm.mirror
		norm.rotation += 90
		norm.calculateSize()
	}

	function clear() {
		norm.source = ""
		nofileloaded.visible = true
	}

	/****************************************************************************************************
	*
	* Zoom code lines inspired by code at:
	*
	* https://gitorious.org/spena-playground/xmcr/source/87a2bfcb6a1f6688e0ed7169c6b72308ad08778d:src/qml/ZoomableImage.qml
	*
	*****************************************************************************************************/

	Flickable {

		id: flickarea
		anchors.fill: parent
		clip: true

		contentHeight: imageContainer.height
		contentWidth: imageContainer.width

		Item {
			id: imageContainer

			width: Math.max(norm.width * norm.scale, flickarea.width)
			height: Math.max(norm.height * norm.scale, flickarea.height)

			TransitionImage {
				id: norm
				property real prevScale
				anchors.centerIn: parent
				asynchronous: false
				function calculateSize() {
					if(settings.fitInWindow) scale = Math.min(flickarea.width / width, flickarea.height / height);
						prevScale = Math.min(scale, 1);
				}
				onScaleChanged: {
					var cursorpos = getanddostuff.getCursorPos()
					var x_ratio = (zoomTowardsCenter ? flickarea.width/2 : cursorpos.x);
					var y_ratio = (zoomTowardsCenter ? flickarea.height/2 : cursorpos.y);
					if ((width * scale) > flickarea.width) {
						var xoff = (x_ratio + flickarea.contentX) * scale / prevScale;
						flickarea.contentX = xoff - x_ratio;
					}
					if ((height * scale) > flickarea.height) {
						var yoff = (y_ratio + flickarea.contentY) * scale / prevScale;
						flickarea.contentY = yoff - y_ratio;
					}
					prevScale = scale;
				}
				onStatusChanged: {
					if (status == Image.Ready) {
						calculateSize();
					}
				}

			}
		}

		// ignore wheel events (use for shortcuts, not for scrolling (scroll+zoom leads to unwanted behaviour))
		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			onWheel: wheel.accepted = true	// ignore mouse wheel
			onPressed: mouse.accepted = false
			onReleased: mouse.accepted = false
			onMouseXChanged: mouse.accepted = false
			onMouseYChanged: mouse.accepted = false
		}
	}

	ScrollBarHorizontal { flickable: flickarea; }
	ScrollBarVertical { flickable: flickarea; }

	function doZoom(zoomin) {

		// Don't zoom if nothing is loaded
		if(thumbnailBar.currentFile == "" || blocked) return;

		// We take the content size of the flickarea, except if image is zoomed out
		// (as then the flickarea contentsize remains at item.size, though the actual image is smaller)
		var w = flickarea.contentWidth
		var h = flickarea.contentHeight
		if(!fullsizeImageLoaded) {
			w = norm.width*norm.scale
			h = norm.height*norm.scale
		}

		if(zoomin) {

			// If first zoom in step, load fullsized image
			if((Math.abs(w-background.width) < norm.width*scaleSpeed
						&& h <= background.height)
					|| (Math.abs(h-background.height) < norm.height*scaleSpeed
						&& w <= background.width)) {
				fullsizeImageLoaded = true
				setSourceSize(imageSize.width, imageSize.height)
				if(imageSize.width >= item.width && imageSize.height >= item.height)
					norm.scale = Math.min(item.width / imageSize.width, item.height / imageSize.height);
			}

			norm.scale += scaleSpeed    // has to come AFTER removing source size!

		} else if(!zoomin && imageSize.width*norm.scale > item.width*scaleSpeed) {

			norm.scale -= scaleSpeed  // has to come BEFORE setting source size!

			// When returned to screen size, we re-set the scaled down version
			if((Math.abs((w-imageSize.width*scaleSpeed)-background.width) < norm.width*scaleSpeed)
					&& (Math.abs(h-imageSize.height*scaleSpeed-background.height) < norm.height*scaleSpeed)) {
				fullsizeImageLoaded = false
				setSourceSize(item.width,item.height)
				if(imageSize.width >= item.width && imageSize.height >= item.height)
					norm.scale = Math.min(flickarea.width / norm.width, flickarea.height / norm.height);
			}

		}

	}


	function getClosingX_x() { return rect.x; }
	function getClosingX_height() { return rect.height; }

	// Rectangle holding the closing x top right
	Rectangle {

		id: rect

		visible: (!slideshowRunning && !settings.hidex) || (slideshowRunning && !settings.slideShowHideQuickinfo)

		// Position it
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.rightMargin: settings.fancyX ? 0 : 5

		// Width depends on type of 'x'
		width: (settings.fancyX ? 3 : 1.5)*settings.closeXsize
		height: (settings.fancyX ? 3 : 1.5)*settings.closeXsize

		// Invisible rectangle
		color: "#00000000"

		// Normal 'x'
		Text {

			id: txt_x

			visible: !settings.fancyX
			anchors.fill: parent

			horizontalAlignment: Qt.AlignRight
			verticalAlignment: Qt.AlignTop

			font.pointSize: settings.closeXsize*1.5
			font.bold: true
			color: "white"
			text: "x"

		}

		// Fancy 'x'
		Image {

			id: img_x

			visible: settings.fancyX
			anchors.right: parent.right
			anchors.top: parent.top

			source: "qrc:/img/closingx.png"
			sourceSize: Qt.size(3*settings.closeXsize,3*settings.closeXsize)

		}

		// Click on either one of them
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			onClicked: {
				if (mouse.button == Qt.RightButton) {
					softblocked = 1
					contextmenuClosingX.popup()
				} else {
					if(settings.trayicon)
						hideToSystemTray()
					else
						quitPhotoQt()
				}
			}
		}

		// The actual context menu
		Menu {
			id: contextmenuClosingX
			style: MenuStyle {
			frame: Rectangle { color: "#0F0F0F"; }
			itemDelegate.background: Rectangle { color: (styleData.selected ? "#4f4f4f" :"#0F0F0F"); }
			}

			MenuItem {
				text: "<font color=\"white\">Hide 'x'</font>"
				onTriggered: {
					settings.hidex = true;
					rect.visible = false;
				}
			}
		}
	}

	// This label is displayed at startup, informing the user how to start
	Text {

		id: nofileloaded

		anchors.fill: item

		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter

		color: "grey"
		font.pointSize: 50
		font.bold: true
		wrapMode: Text.WordWrap

		text: "Open a file to begin"

	}


	Component.onCompleted: setSourceSize(background.width,background.height)

}
