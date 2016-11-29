import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements/"

Rectangle {

	id: thumbnailBar2

	// Stores the total number of images for later use
	property int totalNumberImages: 0

	// Access to clicked index/item
	property int clickedIndex: -1
	property var clickedItem: Item

	// Index of currently hovered item
	property int hoveredIndex: -1

	property string currentFile: ""
	property int currentPos: 0

	property point clickpos: Qt.point(0,0)

	property int normalYPosition: (settings.thumbnailposition == "Top" ? scrollbar.height+2 : thumbnailbarheight_addon-scrollbar.height-2)

	// Is a directory loaded?
	property bool directoryLoaded: false

	property var allFileNames: []

	// Transparent background
	color: "#00000000"

	opacity: 0
	visible: false

	onOpacityChanged: {
		if(opacity == 0) visible = false
		else visible = true
	}

	x: metaData.nonFloatWidth
	y: settings.thumbnailposition == "Bottom"
	   ? background.height-(settings.thumbnailsize+thumbnailbarheight_addon)
	   : 0
	width: parent.width-metaData.nonFloatWidth
	height: settings.thumbnailsize+thumbnailbarheight_addon
	clip: true

	Behavior on opacity { NumberAnimation { duration: 200 } }

	property bool stopLoadingThumbnails: false
	function stopThumbnails() {
		stopLoadingThumbnails = true
	}

	function setupModel(stringlist, pos) {

		verboseMessage("ThumbnailBar::setupModel()",pos + "/" + stringlist.length)

		directoryLoaded = true

		allFileNames = stringlist

		// remove previous index
		clickedIndex = -1
		view.currentIndex = -1

		// Clear model of all thumbnails
		imageModel.clear()

		stopLoadingThumbnails = false

		// THIS IS IMPORTANT!!!
		// Without this, centering on the current item when displaying a new image takes FOREVER (well, up to something like 10 seconds)
		view.contentX = 0

		// Store total number of images
		totalNumberImages = stringlist.length

		// Add elements to model
		for(var j = 0; j < totalNumberImages; ++j)
			imageModel.append({"imageUrl" : stringlist[j], "counter" : j, "loaded" : false})

		// (Re-)set model
		view.model = imageModel

		clickedIndex = pos
		view.currentIndex = pos
		clickedItem = view.currentItem

		// Ensure selected item is centered/visible
		_ensureCurrentItemVisible()

	}

	function reloadThumbnails() {
		setupModel(allFileNames, currentPos)
	}

	function displayImage(pos) {

		mainview.imageLoading = true

		verboseMessage("ThumbnailBar::displayImage()",pos)

		if(!directoryLoaded) return

		// Store some values
		currentFile = imageModel.get(pos).imageUrl;
		currentPos = pos;

		imagewatch.watchFolder(currentFile)

		// Load image
		mainview.loadImage("image://full/" + currentFile)

		// Ensure selected item is centered/visible
		_ensureCurrentItemVisible()

		// Ensure old item is not lifted up anymore
		if(clickedIndex !== pos && clickedIndex != -1)
			clickedItem.y = normalYPosition

		// We use the current{Index,Item} to get the actual view item (not possible otherwise as far as I know)
		view.currentIndex = pos
		clickedIndex = pos
		clickedItem = view.currentItem

		// Ensure new item is lifted up
		if(pos !== -1 && pos !== hoveredIndex)
			clickedItem.y = normalYPosition-settings.thumbnailLiftUp

		hoveredIndex = pos

		// Update quickinfo (position, filename)
		quickInfo.updateQuickInfo(pos, totalNumberImages, currentFile);

	}

	// Ensure selected item is centered/visible
	function _ensureCurrentItemVisible() {

		if(totalNumberImages*(settings.thumbnailsize+settings.thumbnailSpacingBetween) > thumbnailBar.width) {

			// Newly loaded dir => center item
			if(clickedIndex == -1 || settings.thumbnailCenterActive) {
				verboseMessage("ThumbnailBar::displayImage()","Show thumbnail centered")
				positionViewAtIndex(currentPos,ListView.Center)
			} else {
				verboseMessage("ThumbnailBar::displayImage()","Keep thumbnail visible")
				positionViewAtIndex(currentPos,ListView.Contain)
			}
		}

	}

	// Animate auto-scrolling of view
	function positionViewAtIndex(index, loc) {
		autoScrollAnim.running = false
		var pos = view.contentX;
		var destPos;
		view.positionViewAtIndex(index, loc);
		destPos = view.contentX;
		if(loc == ListView.Contain) {
			// Make sure there is a little margin past the thumbnail kept visible
			if(destPos > pos) destPos += settings.thumbnailsize/2
			else if(destPos < pos) destPos -= settings.thumbnailsize/2
			// but ensure that we don't go beyond the view area
			if(destPos < 0) destPos = 0
			if(destPos > view.contentWidth-view.width) destPos = view.contentWidth-view.width
		}
		autoScrollAnim.from = pos;
		autoScrollAnim.to = destPos;
		autoScrollAnim.running = true;
	}
	NumberAnimation { id: autoScrollAnim; target: view; property: "contentX"; duration: 150 }

	// Load next image
	function nextImage() {
		verboseMessage("ThumbnailBar::nextImage()", clickedIndex + " - " + totalNumberImages + " - " + settings.loopthroughfolder)
		if(clickedIndex+1 < totalNumberImages) {
			displayImage(clickedIndex+1);
		} else if(settings.loopthroughfolder) {
			displayImage(0);
		}
	}

	// Load previous image
	function previousImage() {
		verboseMessage("ThumbnailBar::previousImage()", clickedIndex + " - " + settings.loopthroughfolder)
		if(clickedIndex-1 >= 0) {
			displayImage(clickedIndex-1)
		} else if(settings.loopthroughfolder) {
			displayImage(totalNumberImages-1);
		}
	}

	function getNewFilenameAfterDeletion() {
		verboseMessage("ThumbnailBar::getNewFilenameAfterDeletion()",totalNumberImages + " - " + clickedIndex + " - " + totalNumberImages)
		if(totalNumberImages == 1) {
			mainview.clear()
			metaData.clear()
			quickInfo.opacity = 0
			return ""
		}
		if(clickedIndex < totalNumberImages-1)
			return imageModel.get(clickedIndex+1).imageUrl
		return imageModel.get(clickedIndex-1).imageUrl
	}

	function gotoFirstImage() {
		verboseMessage("ThumbnailBar::gotoFirstImage()","Start")
		displayImage(0);
	}
	function gotoLastImage() {
		verboseMessage("ThumbnailBar::gotoLastImage()","End")
		displayImage(totalNumberImages-1);
	}

	// Enable moving of flickable with mouse wheel (i.e., translate vertical to horizontal scroll)
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onWheel: {
			var deltaY = wheel.angleDelta.y
			if(deltaY >= 0) {
				if(view.contentX-deltaY >= 0)
					view.contentX = view.contentX-deltaY
				else
					view.contentX = 0
			} else if(deltaY < 0) {
				if(view.contentWidth >= (view.contentX+view.width-deltaY))
					view.contentX = view.contentX-deltaY
				else
					view.contentX = view.contentWidth-view.width
			}
		}
	}

	// This item make sure, that the thumbnails are displayed centered when their combined width is less than the width of the screen
	Item {

		id: viewcontainer

		anchors.top: parent.top
		anchors.bottom: parent.bottom
		x: (totalNumberImages*settings.thumbnailsize > parent.width ? 0 : (parent.width-totalNumberImages*settings.thumbnailsize)/2)
		width: (totalNumberImages*settings.thumbnailsize > parent.width ? parent.width : totalNumberImages*settings.thumbnailsize)

		ListView {

			id: view

			anchors.fill: parent

			// No bouncing past ends
			boundsBehavior: Flickable.StopAtBounds

			// Set model
			model:  ListModel {
				id: imageModel
				objectName: "model"
			}

			// Set delegate
			delegate: imageDelegate

			// Turn it horizontal
			orientation: ListView.Horizontal

		}

		ScrollBarHorizontal {
			id: scrollbar
			visible: !settings.thumbnailDisable && (view.contentWidth > view.width)
			flickable: view;
			displayAtBottomEdge: settings.thumbnailposition == "Bottom"
		}

	}

	Component {

		id: imageDelegate

		Rectangle {

			id: imgrect

			property var count: counter
			property var path: imageUrl

			x: 0
			y: normalYPosition
			Behavior on y { NumberAnimation { duration: 100 } }

			width: settings.thumbnailsize
			height: settings.thumbnailsize

			visible: !settings.thumbnailDisable

			color: colour.thumbnails_bg

			Image {

				property point p: getCursorPos()
				property point loc: toplevel.mapToItem(view,p.x, p.y)
				source: (((mainview.loadedImageSource != thumbnailBar.currentFile && !loaded) || settings.thumbnailDisable
						  || settings.thumbnailFilenameInstead || (!loaded && stopLoadingThumbnails) || imageUrl==undefined)
								? ""
								: "image://thumb/" + imageUrl)

				x: settings.thumbnailSpacingBetween/2
				y: settings.thumbnailSpacingBetween/2
				width: parent.width-settings.thumbnailSpacingBetween
				height: parent.height-settings.thumbnailSpacingBetween

				fillMode: Image.PreserveAspectFit
				cache: false
				asynchronous: true

				sourceSize: Qt.size(width, height)

				onStatusChanged: {
					if(status == Image.Ready && source != "")
						loaded = true
				}

				Image {
					source: "qrc:/img/emptythumb.png"
					anchors.fill: parent
					cache: false
					sourceSize: Qt.size(width, height)
					visible: !loaded
				}

			}

			ToolTip {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor

				text: getanddostuff.removePathFromFilename(imageUrl)

				onPositionChanged: {
					imgrect.y = normalYPosition + settings.thumbnailLiftUp*(settings.thumbnailposition == "Top" ? 1 : -1)
					hoveredIndex = imgrect.count
				}
				onEntered: {
					imgrect.y = normalYPosition + settings.thumbnailLiftUp*(settings.thumbnailposition == "Top" ? 1 : -1)
					hoveredIndex = imgrect.count
				}
				onExited: {
					if(clickedIndex != imgrect.count && hoveredIndex == imgrect.count)
						imgrect.y = normalYPosition
				}
				// Load thumbnail as main image (timer when pressed to NOT do anything if thumbnails dragged (i.e. mouse position changed))
				onPressed: {
					if(clickedIndex != hoveredIndex)
						clickpos = getCursorPos()
				}
				// On released, i.e. a normal click, we stop the timer and load the image right away
				onReleased: {
					var p = getCursorPos()
					var loc = toplevel.mapToItem(view,p.x, p.y)
					if(Math.abs(clickpos.x-p.x) < 10 && Math.abs(clickpos.y-p.y) < 10)
						displayImage(hoveredIndex)
					else if(imageUrl != imageModel.get(loc/settings.thumbnailsize).imageUrl && currentFile != imageUrl)
						imgrect.y = normalYPosition
				}

			}

			// Filename label (when filename-only NOT enabled)
			Rectangle {

				x: 5
				y: parent.height*0.67

				visible: !settings.thumbnailFilenameInstead && settings.thumbnailWriteFilename

				color: colour.thumbnails_filename_bg

				width: parent.width-10
				height: childrenRect.height+4

				Text {

					x: 2
					y: 2

					width: parent.width-4

					visible: !settings.thumbnailFilenameInstead && settings.thumbnailWriteFilename

					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter

					color: colour.text
					font.bold: true
					font.pointSize: settings.thumbnailFontSize
					wrapMode: Text.WrapAnywhere
					maximumLineCount: 1
					elide: Text.ElideRight

					text: getanddostuff.removePathFromFilename(imageUrl)

				}
			}

			// Filename label (when filename-only IS enabled)
			Rectangle {

				x: 5
				y: 5
				width: parent.width-10
				height: parent.height-10

				visible: settings.thumbnailFilenameInstead
				color: "#00000000"

				Text {

					x: 0
					y: 0
					width: parent.width
					height: parent.height

					visible: settings.thumbnailFilenameInstead

					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					wrapMode: Text.WrapAnywhere
					elide: Text.ElideRight

					color: colour.text
					font.pointSize: settings.thumbnailFilenameInsteadFontSize
					font.bold: true

					text: getanddostuff.removePathFromFilename(imageUrl)
				}
			}

			Component.onCompleted: {
				if(count == currentPos)
					imgrect.y = normalYPosition + settings.thumbnailLiftUp*(settings.thumbnailposition == "Top" ? 1 : -1)
			}

		}

	}

	function show() {
		opacity = 1
	}
	function hide() {
		opacity = 0
	}

	function clickOnThumbnailBar(pos) {
		return contains(thumbnailBar2.mapFromItem(toplevel,pos.x,pos.y))
	}

}
