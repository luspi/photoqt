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
    function setupModel(stringlist, pos) {

        // remove previous index
        previousIndex = -1

        // Clear model of all thumbnails
        imageModel.clear()

        // Store total number of images
        totalNumberImages = stringlist.length

        // Add elements to model
        for(var j = 0; j < totalNumberImages; ++j)
            imageModel.append({"imageUrl" : stringlist[j], "counter" : j, "pre" : true, "smart" : false})

        // (Re-)set model
        gridView.model = imageModel

        // Adjust gridView width
//        gridView.width = stringlist.length*gridView.cellWidth
        gridView.width = stringlist.length*settings.value("Thumbnail/ThumbnailSize")

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
                var x = (pos+0.5)*(thumbnailsize)-0.5*thumbnailBar.width
                var setx = x;
                if(x < 0) x = 0
                else if(x+flick.width > flick.contentWidth) x = flick.contentWidth-flick.width
                flick.contentX = x
            // Ensure visible to the right
            } else if((pos+1)*(thumbnailsize) > visible_x+visible_width) {
                if(pos === totalNumberImages-1)
                    flick.contentX = flick.contentWidth-flick.width
                else
                    flick.contentX = (pos+1.5)*(thumbnailsize)-thumbnailBar.width
            // Ensure visible to the left
            } else {
                if(pos === 0)
                    flick.contentX = 0
                else if((pos-1)*(thumbnailsize) < visible_x)
                    flick.contentX = (pos-0.5)*(thumbnailsize)
            }
        }

        // Ensure loaded item is lifted up
        if(hoveredIndex !== pos) {
            gridView.currentItem.y = gridView.currentItem.y-thumbnailliftup
        }
        if(previousIndex != -1 && hoveredIndex != previousIndex) {
            previousItem.y = previousItem.y+thumbnailliftup
        }

        // Store selected item
        previousItem = gridView.currentItem
        previousIndex = gridView.currentIndex

        // Update quickinfo (position, filename)
        quickInfo.updateQuickInfo(pos, totalNumberImages, imageUrl);

    }

    function getCenterPos() {
        return (flick.contentX+(flick.width/2))/(settings.value("Thumbnail/ThumbnailSize")*1)
    }

    // Load next image
    function nextImage() {
        if(previousIndex+1 < totalNumberImages) {
            displayImage(previousIndex+1);
            scrollTimer.restart()
        }
    }

    // Load previous image
    function previousImage() {
        if(previousIndex > 0) {
            displayImage(previousIndex-1)
            scrollTimer.restart()
        }
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
            var centerpos = (flick.contentX+flick.width/2)/(settings.value("Thumbnail/ThumbnailSize")*1)
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

            // The actual thumbnail image
            Image {

                id: img

                // Store some values
                property var count: counter
                property var path: imageUrl

                // Set position
                y: thumbnailbarheight_addon-5
                x: 0

                // Adjust size
                width: thumbnailsize
                height: thumbnailsize

                sourceSize: Qt.size(thumbnailsize,thumbnailsize)

                // Set image source (preload or normal) and displayed source dimension
                source: (pre ? "" : ("image://thumb/" + (smart ? "__**__smart" : "") + imageUrl))

                // Adjust different values
                fillMode: Image.PreserveAspectFit
                cache: false
                asynchronous: true

                MouseArea {

                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true

                    // Lift item up on hover
                    onEntered: {
                        hoveredIndex = img.count
                        if(img.count != gridView.currentIndex/* && totalNumberImages < maxNumberForAnimation*/)
                            img.y = img.y-thumbnailliftup;
                    }
                    // Remove item lift when leaving it
                    onExited: {
                        hoveredIndex = -1
                        if(gridView.currentIndex != img.count/* && totalNumberImages < maxNumberForAnimation*/)
                            img.y = img.y+thumbnailliftup;
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
                // Rectangle+Text to display filename
                Rectangle {

                    id: filenamerect

                    x: 3
                    y: parent.height*0.2

                    // spacing to the left&right: 3 pixel
                    width: parent.width-6
                    height: 30

                    // Some styling
                    color: pre ? "#88000000" : "#00000000"
                    visible: pre
                    radius: 3

                    // The actual filename text
                    Text {

                        id: filename

                        // Set filename (we need to filter it out of the path)
                        property var l: imageUrl.split("/")
                        text: pre ? l[l.length-1] : ""

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

        ListView {

            id: gridView

            property int thumbnailsize: settings.value("Thumbnail/ThumbnailSize")*1
            property int thumbnailspacing: settings.value("Thumbnail/ThumbnailSpacingBetween")*1

            // Set model and delegate
            model: imageModel
            delegate: imageDelegate

            orientation: ListView.Horizontal

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
