import QtQuick 2.3
import QtQuick.Controls.Styles 1.2
import QtQuick.Controls 1.2

import "../elements"

Item {

	id: item

	// Position item
	x: settings.borderAroundImg
	y: (settings.thumbnailKeepVisible && settings.thumbnailposition == "Top" ? settings.borderAroundImg+thumbnailBar.height : settings.borderAroundImg)
	width: background.width - 2*settings.borderAroundImg
	height: (settings.thumbnailKeepVisible ? background.height-thumbnailBar.height+thumbnailbarheight_addon/2 : background.height)-2*settings.borderAroundImg

	// How fast do we zoom in/out
	property real scaleSpeed: 0.1

	// Keep track of where we are in zooming
	property bool zoomTowardsCenter: false
	property double imageRotatedAndRescaled: 1

	// Some image stuff
	property bool imageWidthLargerThanHeight: true
	property size imageSize: Qt.size(0,0)
	property bool fullsizeImageLoaded: false
	function isFullsizeImageLoaded() { return fullsizeImageLoaded; }

	// Store the rotation/zoom (if enabled)
	property var storeRotation: {"":0}
	property var storeZoom: {"":[]}
	// This info is needed to set the right image when restoring zoom
	property string zoomedDirection: ""

	function noFilterResultsFound() {
		noresultsfound.visible = true;
		norm.source = ""
	}

	// Set image
	function setImage(path, animated) {

		verboseMessage("Display::setImage()", animated + " - " + path)

		// Store rotation/zoom
		if(norm.source != "" && !nofileloaded.visible && !noresultsfound.visible) {

			if(settings.rememberZoom && zoomedDirection != "")
				storeZoom[norm.source] = [norm.scale,zoomedDirection,flickarea.contentX,flickarea.contentY]
			if(settings.rememberRotation)
				storeRotation[norm.source] = norm.rotation

		}

		// Hide 'nothing loaded' message and arrows
		nofileloaded.visible = false
		metadataarrow.visible = false
		mainmenuarrow.visible = false
		quicksettingsarrow.visible = false
		noresultsfound.visible = false

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

		// Restore rotation/zoom if saved
		if(Object.keys(storeRotation).indexOf(path) != -1 || Object.keys(storeZoom).indexOf(path) != -1) {

			if((Object.keys(storeRotation).indexOf(path) != -1) && storeRotation[path] !== 0 && settings.rememberRotation) {
				norm.rotation = storeRotation[path]
				norm.calculateSize()
				if(Math.abs(norm.rotation%180) == 90)
					setSourceSize(item.height,item.width)
				else
					setSourceSize(item.width,item.height)
			}

			if(Object.keys(storeZoom).indexOf(path) != -1 && settings.rememberZoom) {

				if(storeZoom[path][1] == "in") {
					fullsizeImageLoaded = true
					setSourceSize(imageSize.width, imageSize.height)
					if(imageSize.width >= item.width && imageSize.height >= item.height)
						norm.scale = Math.min(item.width / imageSize.width, item.height / imageSize.height);
				} else if(storeZoom[path][1] == "out") {
					fullsizeImageLoaded = false
					setSourceSize(item.width,item.height)
					if(imageSize.width >= item.width && imageSize.height >= item.height)
						norm.scale = Math.min(flickarea.width / norm.width, flickarea.height / norm.height);
				}

				norm.scale = storeZoom[path][0]
				flickarea.contentX = storeZoom[path][2]
				flickarea.contentY = storeZoom[path][3]

			}

		// If the above check succeeds, then the image was changed already, and so we don't want to display this box anymore...
		} else if(metaData.orientation != 1 && settings.exifrotation == "Ask") {
			rotateconfirm.show()
		}

		imageRotatedAndRescaled = 1;

	}

	// Update source sizes
	function setSourceSize(w,h) {
		norm.forceSourceSizeToBoth(Qt.size(w,h))
	}

	function resetZoom(loadNewImage) {

		verboseMessage("Display::resetZoom()",loadNewImage)

		fullsizeImageLoaded = false

		if(imageRotatedAndRescaled != 1) norm.scale /= imageRotatedAndRescaled
		imageRotatedAndRescaled = 1

		// Re-set source size to screen size
		setSourceSize(item.width,item.height)

		// Reset scaling
		norm.resetZoom(loadNewImage)

		zoomedDirection = ""

	}

	function resetRotation() {
		verboseMessage("Display::resetRotation()","")
		norm.rotation = 0
		norm.mirror = false
		fullsizeImageLoaded = false
		if(imageRotatedAndRescaled != 1) norm.scale /= imageRotatedAndRescaled
		imageRotatedAndRescaled = 1
		setSourceSize(item.width,item.height)
	}

	function zoomIn(towardsCenter) {
		verboseMessage("Display::zoomIn()",towardsCenter)
		zoomTowardsCenter = (towardsCenter !== undefined ? towardsCenter : false)
		doZoom(true)
	}
	function zoomOut(towardsCenter) {
		verboseMessage("Display::zoomOut()",towardsCenter)
		zoomTowardsCenter = (towardsCenter !== undefined ? towardsCenter : false)
		doZoom(false)
	}

	function zoomActual() {
		verboseMessage("Display::zoomActual()","")
		// the current offset (as a ratio)
		var x_ratio = ((flickarea.width/2)+flickarea.contentX)/flickarea.contentWidth
		var y_ratio = ((flickarea.height/2)+flickarea.contentY)/flickarea.contentHeight
		norm.scale = 1
		fullsizeImageLoaded = true
		setSourceSize(imageSize.width, imageSize.height)
		// reset the previous offset ratio (in effect this yields a 'zoom to center until actual size')
		flickarea.contentX = (flickarea.contentWidth)*x_ratio-flickarea.width/2
		flickarea.contentY = (flickarea.contentHeight)*y_ratio-flickarea.height/2
	}

	function rotateRight() {
		verboseMessage("Display::rotateRight()","")
		norm.rotation += 90
		if(!fullsizeImageLoaded) {
			norm.calculateSize()
			setSourceSize(item.width,item.height)

			if(imageRotatedAndRescaled == 1) {
				var fraction1 = 1
				var fraction2 = 1

				if(flickarea.contentWidth > item.width)
					fraction1 = item.width/flickarea.contentWidth
				if(flickarea.contentHeight > item.height)
					fraction2 = item.height/flickarea.contentHeight

				imageRotatedAndRescaled = Math.min(fraction1,fraction2)
				norm.scale *= imageRotatedAndRescaled

			} else {

				norm.scale /= imageRotatedAndRescaled
				imageRotatedAndRescaled = 1;

			}
		}
	}

	function rotateLeft() {
		verboseMessage("Display::rotateLeft()","")
		norm.rotation -= 90
		if(!fullsizeImageLoaded) {
			norm.calculateSize()
			setSourceSize(item.width,item.height)


			if(imageRotatedAndRescaled == 1) {

				var fraction1 = 1
				var fraction2 = 1

				if(flickarea.contentWidth > item.width)
					fraction1 = item.width/flickarea.contentWidth
				if(flickarea.contentHeight > item.height)
					fraction2 = item.height/flickarea.contentHeight

				imageRotatedAndRescaled = Math.min(fraction1,fraction2)
				norm.scale *= imageRotatedAndRescaled

			} else {

				norm.scale /= imageRotatedAndRescaled
				imageRotatedAndRescaled = 1;

			}
		}
	}

	function flipHorizontal() {
		verboseMessage("Display::flipHorizontal()","")
		norm.mirror = !norm.mirror
		norm.calculateSize()
	}

	function flipVertical() {
		verboseMessage("Display::flipVertical()","")
		norm.rotation += 90
		norm.mirror = !norm.mirror
		norm.rotation += 90
		norm.calculateSize()
	}

	function clear() {
		norm.source = ""
		nofileloaded.visible = true
	}

	function getImageRect() {
		var w = norm.width*norm.scale
		var h = norm.height*norm.scale
		var x = (background.width-w)/2
		var y = (background.height-h)/2
		return [x,y,w,h]
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

			width: Math.max((norm.rotation%180 == 0 ? norm.width : norm.height) * norm.scale, flickarea.width)
			height: Math.max((norm.rotation%180 == 0 ? norm.height : norm.width) * norm.scale, flickarea.height)

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

		verboseMessage("Display::doZoom()",zoomin)

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
				zoomedDirection = "in"
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
				zoomedDirection = "out"
			}

			// when zooming out right after loading image, this variable would stay unset (even though the image is zoomed out)
			if(zoomedDirection == "")
				zoomedDirection = "out"

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
		anchors.rightMargin: settings.fancyX ? -settings.borderAroundImg : -settings.borderAroundImg+5
		anchors.topMargin: settings.fancyX ? -settings.borderAroundImg : -settings.borderAroundImg+5

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
			color: colour.quickinfo_text
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
			frame: Rectangle { color: colour.menu_frame; }
			itemDelegate.background: Rectangle { color: (styleData.selected ? colour.menu_bg_highlight : colour.menu_bg); }
			}

			MenuItem {
				text: "<font color=\"" + colour.menu_text + "\">" + qsTr("Hide") + " 'x'</font>"
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
		anchors.rightMargin: Math.max(metadataarrow.width,quicksettingsarrow.width)+25
		anchors.leftMargin: Math.max(metadataarrow.width,quicksettingsarrow.width)+25

		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter

		color: colour.bg_label
		font.pointSize: 50
		font.bold: true
		wrapMode: Text.WordWrap

		text: qsTr("Open a file to begin")

	}

	// Arrow pointing to metadata widget
	Image {
		id: metadataarrow
		visible: settings.exifenablemousetriggering
		x: 0
		y: metaData.y+metaData.height/2-height/2
		source: "qrc:/img/mainview/arrowleft.png"
		width: 150
		height: 60
	}

	// Arrow pointing to quicksettings widget
	Image {
		id: quicksettingsarrow
		visible: settings.quickSettings
		x: background.width-width-5
		y: quicksettings.y+quicksettings.height/2-height/2
		source: "qrc:/img/mainview/arrowright.png"
		width: 150
		height: 60
	}

	// Arrow pointing to mainmenu widget
	Image {
		id: mainmenuarrow
		x: mainmenu.x+(mainmenu.width-width)/2
		y: settings.thumbnailposition == "Bottom" ? 0 : background.height-height
		source: settings.thumbnailposition == "Bottom" ? "qrc:/img/mainview/arrowup.png" : "qrc:/img/mainview/arrowdown.png"
		width: 72
		height: 120
	}

	Text {

		id: noresultsfound

		anchors.fill: item
		visible: false

		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter

		color: colour.bg_label
		font.pointSize: 50
		font.bold: true
		wrapMode: Text.WordWrap

		text: qsTr("No results found...")

	}


	CustomConfirm {
		id: rotateconfirm
		header: qsTr("Rotate Image?")
		description: qsTr("The Exif data of this image says, that this image is supposed to be rotated.") + "<br><br>" + qsTr("Do you want to apply the rotation?")
		confirmbuttontext: qsTr("Yes, do it")
		rejectbuttontext: qsTr("No, don't")
		showDontAskAgain: true
		onAccepted: {
			// 1 = Do nothing
			// 2 = Horizontally Flipped
			if(metaData.orientation == 2) {
				image.flipHorizontal()
			// 3 = Rotated by 180 degrees
			} else if(metaData.orientation == 3) {
				image.rotateRight()
				image.rotateRight()
			// 4 = Rotated by 180 degrees and flipped horizontally
			} else if(metaData.orientation == 4) {
				image.rotateRight()
				image.rotateRight()
				image.flipHorizontal()
			// 5 = Rotated by 270 degrees and flipped horizontally
			} else if(metaData.orientation == 5) {
				image.rotateRight()
				image.flipHorizontal()
			// 6 = Rotated by 270 degrees
			} else if(metaData.orientation == 6)
				image.rotateRight()
			// 7 = Flipped Horizontally and Rotated by 90 degrees
			else if(metaData.orientation == 7) {
				image.rotateLeft()
				image.flipHorizontal()
			// 8 = Rotated by 90 degrees
			} else if(metaData.orientation == 8)
				image.rotateLeft()

			if(alwaysDoThis)
				settings.exifrotation = "Always"
		}

		onRejected: {
			if(alwaysDoThis)
				settings.exifrotation = "Never"
		}
	}


	Component.onCompleted: setSourceSize(background.width,background.height)

}
