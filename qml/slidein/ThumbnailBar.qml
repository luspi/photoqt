import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements/"

Rectangle {

	id: thumbnailBar

	// Stores the total number of images for later use
	property int totalNumberImages: 0

	// Access to clicked index/item
	property int clickedIndex: -1
	property var clickedItem: Item

	// Index of currently hovered item
	property int hoveredIndex: -1

	property string currentFile: ""

	property point clickpos: Qt.point(0,0)

	property int normalYPosition: thumbnailbarheight_addon-12

	// Is a directory loaded?
	property bool directoryLoaded: false

	// Transparent background
	color: "#00000000"

	x: 0
	y: settings.thumbnailposition == "Bottom"
	   ? background.height-(settings.thumbnailKeepVisible ? settings.thumbnailsize+thumbnailbarheight_addon : -safetyDistanceForSlidein)
	   : settings.thumbnailKeepVisible ? 0 : -height-safetyDistanceForSlidein
	width: background.width
	height: settings.thumbnailsize+thumbnailbarheight_addon

	function setupModel(stringlist, pos) {

		directoryLoaded = true

		// remove previous index
		clickedIndex = -1

		// Clear model of all thumbnails
		imageModel.clear()

		// Store total number of images
		totalNumberImages = stringlist.length

		// Add elements to model
		for(var j = 0; j < totalNumberImages; ++j)
			imageModel.append({"imageUrl" : stringlist[j], "counter" : j, "pre" : true, "smart" : false})

		// (Re-)set model
		view.model = imageModel

		// Adjust gridView width
		view.width = stringlist.length*settings.thumbnailsize

	}

	function displayImage(pos) {

		if(!directoryLoaded) return

		// Store some values
		currentFile = imageModel.get(pos).imageUrl;

		// Load image
		if(getanddostuff.isImageAnimated(currentFile)) {
			image.setImage("file://" + currentFile, true)
		} else {
			image.setImage("image://full/" + currentFile, false)
		}

		// Ensure selected item is centered/visible
		if(totalNumberImages*(settings.thumbnailsize+settings.thumbnailSpacingBetween) > thumbnailBar.width) {

			// Newly loaded dir => center item
			if(clickedIndex == -1 || settings.thumbnailCenterActive) {
				view.positionViewAtIndex(pos,ListView.Center)
			} else {
				view.positionViewAtIndex(pos-1,ListView.Contain)
				view.positionViewAtIndex(pos+1,ListView.Contain)
				scrollTimer.restart()
			}
		}

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

	function getCenterPos() {
		return (view.contentX+(view.width/2))/(settings.thumbnailsize)
	}

	// Load next image
	function nextImage() {
		if(clickedIndex+1 < totalNumberImages) {
			displayImage(clickedIndex+1);
			scrollTimer.restart()
		} else if(settings.loopthroughfolder) {
			displayImage(0);
		}
	}

	// Load previous image
	function previousImage() {
		if(clickedIndex-1 >= 0) {
			displayImage(clickedIndex-1)
			scrollTimer.restart()
		} else if(settings.loopthroughfolder) {
			displayImage(totalNumberImages-1);
		}
	}

	function getNewFilenameAfterDeletion() {
		console.log("after:",clickedIndex,totalNumberImages)
		if(totalNumberImages == 1) {
			image.clear()
			metaData.clear()
			quickInfo.opacity = 0
			return ""
		}
		if(clickedIndex < totalNumberImages-1)
			return imageModel.get(clickedIndex+1).imageUrl
		return imageModel.get(clickedIndex-1).imageUrl
	}

	function gotoFirstImage() {
		displayImage(0);
	}
	function gotoLastImage() {
		displayImage(totalNumberImages-1);
	}

	// Load proper thumbnail at position 'pos' (smart == true means: ONLY IF IT EXISTS)
	function reloadImage(pos, smart) {
		if(pos < 0 || pos >= totalNumberImages) return
		var imageUrl = imageModel.get(pos).imageUrl;
		imageModel.set(pos,{"imageUrl" : imageUrl, "counter" : pos, "pre" : false, "smart" : smart})
	}

	/**********************************************************/
	// This image (and timer below) takes care of 'commit'ing the thumbnail database images
	Image {
		id: hiddenImageCommitDatabase
		visible: false
		source: ""
		cache: false
	}
	Timer {
		id: timerhiddenImageCommitDatabase
		interval: 1000
		running: false
		repeat: false
		onTriggered: {
			hiddenImageCommitDatabase.source = "image://thumb/__**__" + Math.random()
		}
	}
	/**********************************************************/

	// If the view was scrolled/moved, this timer is set off
	Timer {
		id: scrollTimer
		interval: 300
		running: false
		repeat: false
		onTriggered: {
			// Item in the center of the screen
			var centerpos = (view.contentX+view.width/2)/(settings.thumbnailsize)
			// Emit 'scrolled' signal
			toplevel.thumbScrolled(centerpos)
		}
	}

	// Enable moving of flick with mouse wheel
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onWheel: {
			if(wheel.angleDelta.y >= 0 && view.contentX-50 >= 0)
				view.contentX = view.contentX-50
			else if(wheel.angleDelta.y < 0 && view.contentWidth >= (view.contentX+view.width+50))
				view.contentX = view.contentX+50
			scrollTimer.restart()

		}
	}

	// This item make sure, that the thumbnails are displayed centered when their combined width is less than the width of the screen
	Item {

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

			// When flicking finished
			onMovementEnded: {
				// Item in center of flickable
				var centerpos = getCenterPos()
				// Emit 'scrolled' signal
				toplevel.thumbScrolled(centerpos)
			}

		}

		ScrollBarHorizontal {
			visible: !settings.thumbnailDisable
			flickable: view;
			displayAtBottomEdge: settings.thumbnailposition == "Bottom"
			onScrollFinished: scrollTimer.restart()
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

			width: settings.thumbnailsize
			height: settings.thumbnailsize

			visible: !settings.thumbnailDisable

			color: colour.thumbnails_bg

			border.color: colour.thumbnails_border
			border.width: 1

			Image {

				id: img

				// DO NOT SET SOURCESIZE - THIS WOULD BREAK 'SMART THUMBNAILS'
				// sourceSize: Qt.size(settings.thumbnailsize,settings.thumbnailsize)

				// Set image source (preload or normal) and displayed source dimension
				source: (settings.thumbnailDisable ? "" : (pre ? "qrc:/img/emptythumb.png" : "image://thumb/" + (smart ? "__**__smart" : "") + imageUrl))

				visible: !pre && !settings.thumbnailDisable

				// Set position
				x: settings.thumbnailSpacingBetween/2
				y: settings.thumbnailSpacingBetween/2

				// Adjust size
				width: parent.width-settings.thumbnailSpacingBetween
				height: parent.height-settings.thumbnailSpacingBetween

				fillMode: Image.PreserveAspectFit
				cache: false
				asynchronous: true

				// Catch 'loading completed' of thumbnail
				onStatusChanged: {
					// If image is ready and it's not a preload image
					if(img.status == Image.Ready) {
						if(img.sourceSize == Qt.size(1,1)) {
							didntLoadThisThumbnail(counter);
							imageModel.set(counter,{"imageUrl" : imageUrl, "counter" : counter, "pre" : true, "smart" : false})
						} else {
							// Start timer to commit thumbnail database
							timerhiddenImageCommitDatabase.restart()
							loadMoreThumbnails();
						}
					}
				}
			}

			MouseArea {

				cursorShape: Qt.PointingHandCursor
				anchors.fill: parent
				hoverEnabled: true

				// Lift item up on hover
				onPositionChanged: {
					if(imgrect.y == normalYPosition)
						imgrect.y = normalYPosition-settings.thumbnailLiftUp
					hoveredIndex = imgrect.count
				}
				onEntered: {
					if(imgrect.y == normalYPosition)
						imgrect.y = normalYPosition-settings.thumbnailLiftUp
					hoveredIndex = imgrect.count
				}
				// Remove item lift when leaving it
				onExited: {
					if(clickedIndex != imgrect.count && hoveredIndex == imgrect.count)
						imgrect.y = normalYPosition
				}
				// Load thumbnail as main image (timer when pressed to NOT do anything if thumbnails dragged (i.e. mouse position changed))
				onPressed: {
					if(clickedIndex != hoveredIndex) {
						clickpos = getanddostuff.getCursorPos()
						displaytimer.start()
					}
				}
				// On released, i.e. a normal click, we stop the timer and load the image right away
				onReleased: {
					displaytimer.stop()
					displayImage(hoveredIndex)
				}
				// Load image (see two comments above for more details)
				Timer {
					id: displaytimer
					interval: 150
					running: false
					repeat: false
					onTriggered: {
						var p = getanddostuff.getCursorPos()
						if(Math.abs(clickpos.x-p.x) < 10 && Math.abs(clickpos.y-p.y) < 10)
							displayImage(hoveredIndex)
					}
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
					font.pointSize: Math.max(settings.thumbnailFontSize*font_multiplier,2)
					wrapMode: Text.WrapAnywhere
					maximumLineCount: 1
					elide: Text.ElideRight

					property var p: imageUrl.split("/")
					text: p[p.length-1]

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
					font.pointSize: settings.thumbnailFilenameInsteadFontSize*font_multiplier
					font.bold: true

					property var p: imageUrl.split("/")
					text: p[p.length-1]
				}
			}
		}
	}
}
