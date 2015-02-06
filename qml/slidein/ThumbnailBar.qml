import QtQuick 2.3
import QtQuick.Controls 1.2


Rectangle {

    id: thumbnailBar

    // Transparent background
    color: "#00000000"

    // Store the total number of images (for loop, and for quickinfo)
    property int totalNumberImages: 0

    // Update quickinfo (position in dir, filename)
	signal updateQuickInfo()

    // We need those two to manage the current item as we use custom styling for hovered/selected item (previous&current)
	property var previousItem: Item
    property int previousIndex: -1
    property int hoveredIndex: -1

    property int startedLoading: 0


    // Setup a new model
    function setupModel(stringlist) {

        // remove previous index
        previousIndex = -1

        // Clear model of all thumbnails
        imageModel.clear()

        // Store total number of images
        totalNumberImages = stringlist.length

        // Add elements to model
        for (var i = 0; i < totalNumberImages; ++i)
            imageModel.append({"imageUrl" : stringlist[i], "counter" : i, "pre" : true, "smart" : false})

        // (Re-)set model
        gridView.model = imageModel

        // Adjust gridView width
        gridView.width = stringlist.length*gridView.cellWidth

    }

    // Display an image in large main view
    function displayImage(pos) {

        // Store some values
        var imageUrl = imageModel.get(pos).imageUrl;
        var thumbnailliftup = settings.value("Thumbnail/ThumbnailLiftUp")*1
        var thumbnailsize = settings.value("Thumbnail/ThumbnailSize")*1
        var thumbnailspacing = settings.value("Thumbnail/ThumbnailSpacingBetween")*1

        // Load image
        image.source = "image://full/" + imageUrl

        // Store new position
        gridView.currentIndex = pos

        // Ensure selected item is centered/visible
        if(gridView.width > thumbnailBar.width) {

            // content x and width of flick
            var visible_x = flick.visibleArea.xPosition*gridView.width
            var visible_width = flick.visibleArea.widthRatio*gridView.width

            // Newly loaded dir => center item
            if(previousIndex == -1) {
                var x = (pos+0.5)*(thumbnailsize+thumbnailspacing)-0.5*thumbnailBar.width
                flick.contentX = (x >= 0 ? x : 0)
            // Ensure visible to the right
            } else if((pos+1)*(thumbnailsize+thumbnailspacing) > visible_x+visible_width)
                    flick.contentX = (pos+1.5)*(thumbnailsize+thumbnailspacing)-thumbnailBar.width
            // Ensure visible to the left
            else
                if((pos-1)*(thumbnailsize+thumbnailspacing) < visible_x)
                    flick.contentX = (pos-0.5)*(thumbnailsize+thumbnailspacing)
        }

        // Ensure loaded item is lifted up
        if(hoveredIndex != pos) gridView.currentItem.y = gridView.currentItem.y-thumbnailliftup
        if(previousIndex != -1 && hoveredIndex != previousIndex) previousItem.y = previousItem.y+thumbnailliftup

        // Store selected item
        previousItem = gridView.currentItem
        previousIndex = gridView.currentIndex

        // Update quickinfo (position, filename)
        quickInfo.updateQuickInfo(pos, totalNumberImages, imageUrl);

    }

    function getCenterPos() {
        return (flick.contentX+flick.width/2)/(settings.value("Thumbnail/ThumbnailSize")*1+settings.value("Thumbnail/ThumbnailSpacingBetween")*1)
    }

    // Load next image
    function nextImage() {
        displayImage(previousIndex+1);
        scrollTimer.restart()
    }

    // Load previous image
    function previousImage() {
        displayImage(previousIndex-1)
        scrollTimer.restart()
    }

    // Load proper thumbnail at position 'pos' (smart == true means: ONLY IF IT EXISTS)
    function reloadImage(pos, smart) {
        ++startedLoading
        var imageUrl = imageModel.get(pos).imageUrl;
        imageModel.set(pos,{"imageUrl" : imageUrl, "counter" : pos, "pre" : false, "smart" : smart})
    }

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

    // If the view was scrolled/moved, this timer is set off
    Timer {
        id: scrollTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            // Item in the center of the screen
            var centerpos = (flick.contentX+flick.width/2)/(settings.value("Thumbnail/ThumbnailSize")*1+settings.value("Thumbnail/ThumbnailSpacingBetween")*1)
            // Emit 'scrolled' signal
            toplevel.thumbScrolled(centerpos)
        }
    }

    // Enable moving of flick with mouse wheel
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onWheel: {
			if(wheel.angleDelta.y >= 0 && flick.contentX-50 >= 0)
				flick.contentX = flick.contentX-50
            else if(wheel.angleDelta.y < 0 && flick.contentWidth >= (flick.contentX+flick.width+50))
				flick.contentX = flick.contentX+50
            scrollTimer.restart()

		}
	}

    // Model of thumbnail bar
    ListModel {
        id: imageModel
        objectName: "model"
    }

    // Individual Element of model
    Component {
        id: imageDelegate
        Row {

            // Store some values
            property int thumbnailsize: settings.value("Thumbnail/ThumbnailSize")*1
            property int thumbnailbarsize: thumbnailsize+thumbnailbarheight_addon
            property int thumbnailliftup: settings.value("Thumbnail/ThumbnailLiftUp")*1
            property int thumbnailspacing: settings.value("Thumbnail/ThumbnailSpacingBetween")*1

            Rectangle {

                id: imgrect

                // half-transparent background
                color: "#88000000"

                // Set a border
                border.color: "#AA000000"
                border.width: 1

                // Adjust position
                x: 0
                y: thumbnailbarheight_addon-5

                // Set width/height
                width: gridView.cellWidth
                height: gridView.cellHeight+2*thumbnailspacing

                // The actual thumbnail image
                Image {

                    id: img

                    // Store some values
                    property var count: counter
                    property var path: imageUrl

                    // Set position
                    y: thumbnailspacing
                    x: thumbnailspacing/2

                    // Adjust size
                    width: thumbnailsize
                    height: thumbnailsize

                    // Set image source (preload or normal) and displayed source dimension
                    source: (pre ? "qrc:/img/emptythumb.png" : ("image://thumb/" + (smart ? "__**__smart" : "") + imageUrl))

                    // Adjust different values
                    fillMode: Image.PreserveAspectFit
                    clip: true
                    cache: true
                    smooth: true
                    asynchronous: true

                    verticalAlignment: Image.AlignTop

                    MouseArea {

                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        hoverEnabled: true

                        // Lift item up on hover
                        onEntered: {
                            hoveredIndex = img.count
                            if(img.count != gridView.currentIndex)
                                imgrect.y = imgrect.y-thumbnailliftup;
                        }
                        // Remove item lift when leaving it
                        onExited: {
                            hoveredIndex = -1
                            if(gridView.currentIndex != img.count)
                                imgrect.y = imgrect.y+thumbnailliftup;
                        }
                        // Load thumbnail as main image
                        onClicked: {
                            if(previousIndex != index) {
                                displayImage(index)
                            }
                        }
                    }
                    // Catch 'loading completed' of thumbnail
                    onStatusChanged: {
                        // If image is ready and it's not a preload image
                        if(img.status == Image.Ready && pre == false) {
                            --startedLoading;
                            // A size of (1,1) means, the image was smartly loaded and didn't exist yet -> re-set preload thumbnail
                            if(img.sourceSize == Qt.size(1,1)) {
                                didntLoadThisThumbnail(counter);
                                imageModel.set(counter,{"imageUrl" : imageUrl, "counter" : counter, "pre" : true, "smart" : false})
                            } else {
                                // Start timer to commit thumbnail database
                                timerhiddenImageCommitDatabase.restart()
                                if(startedLoading == 0)
                                    loadMoreThumbnails();
                            }
                        }

                    }
                }

                // Rectangle+Text to display filename
                Rectangle {

                    id: filenamerect

                    x: 3
                    y: parent.height*0.67

                    // spacing to the left&right: 3 pixel
                    width: parent.width-6
                    height: parent.height-y

                    // Some styling
                    color: "#88000000"
                    visible: settings.value("Thumbnail/ThumbnailWriteFilename")*1
                    radius: 3

                    // The actual filename text
                    Text {

                        id: filename

                        // Set filename (we need to filter it out of the path)
                        property var l: imageUrl.split("/")
                        text: l[l.length-1]

                        // Same size as parent of course
                        anchors.fill: parent

                        // text is white, bold, and a certain size
                        color: "white"
                        font.bold: true
                        font.pointSize: settings.value("Thumbnail/ThumbnailFontSize")*1

                        // Some text settings
                        maximumLineCount: 2
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight

                        // Center text in middle of item
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                    }
                }
            }
        }
    }   // END Component - individual model element

    // Scroll area containing the thumbnail view
	Flickable {

		id: flick

        // Maximum size
		anchors.fill: parent

        // Adjust size
        contentHeight: gridView.height
        contentWidth: (parent.width < gridView.width ? gridView.width : parent.width)

        // Behaviour
        clip: true
		flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
//        maximumFlickVelocity: 0

        GridView {

            id: gridView

            property int thumbnailsize: settings.value("Thumbnail/ThumbnailSize")*1
            property int thumbnailspacing: settings.value("Thumbnail/ThumbnailSpacingBetween")*1

            // Center the view (if smaller than the Flickable)
            anchors.horizontalCenter: parent.horizontalCenter

            // Set model and delegate
            model: imageModel
            delegate: imageDelegate

            // Set fixed cell size
            cellWidth: thumbnailsize+thumbnailspacing
            cellHeight: thumbnailsize

            // Set flow
            flow: GridView.TopToBottom

        }

        // When flicking finished
        onMovementEnded: {
            // Item in center of flickable
            var centerpos = getCenterPos()
            // Emit 'scrolled' signal
            toplevel.thumbScrolled(centerpos)
        }

	}

}
