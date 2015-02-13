import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {

    id: thumbnailBar

    // Stores the total number of images for later use
    property int totalNumberImages: 0

    // Access to clicked index/item
    property int clickedIndex: -1
    property var clickedItem: Item

    // Index of currently hovered item
    property int hoveredIndex: -1

    // Transparent background
    color: "#00000000"

    function setupModel(stringlist, pos) {

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
        view.width = stringlist.length*settings.value("Thumbnail/ThumbnailSize")

    }

    function displayImage(pos) {

        // Store some values
        var imageUrl = imageModel.get(pos).imageUrl;
        var thumbnailliftup = settings.value("Thumbnail/ThumbnailLiftUp")*1
        var thumbnailsize = settings.value("Thumbnail/ThumbnailSize")*1
        var thumbnailspacing = settings.value("Thumbnail/ThumbnailSpacingBetween")*1

        // Load image
        if(getimageinfo.isAnimated(imageUrl))
            image.setAnimatedImage("file://" + imageUrl)
        else
            image.setNormalImage("image://full/" + imageUrl)
//            image.source = "image://full/" + imageUrl

        // Ensure selected item is centered/visible
        if(view.width > thumbnailBar.width) {

            // content x and width of flick
            var visible_x = view.visibleArea.xPosition*view.width
            var visible_width = view.visibleArea.widthRatio*view.width

            // Newly loaded dir => center item
            if(clickedIndex == -1) {
                var x = (pos+0.5)*(thumbnailsize)-0.5*thumbnailBar.width
                var setx = x;
                if(x < 0) x = 0
                else if(x+view.width > view.contentWidth) x = view.contentWidth-view.width
                view.contentX = x
            // Ensure visible to the right
            } else if((pos+1)*(thumbnailsize) > visible_x+visible_width) {
                if(pos === totalNumberImages-1)
                    view.contentX = view.contentWidth-view.width
                else
                    view.contentX = (pos+1.5)*(thumbnailsize)-thumbnailBar.width
            // Ensure visible to the left
            } else {
                if(pos === 0)
                    view.contentX = 0
                else if((pos-1)*(thumbnailsize) < visible_x)
                    view.contentX = (pos-0.5)*(thumbnailsize)
            }
        }

        // Ensure old item is not lifted up anymore
        if(clickedIndex !== pos && clickedIndex != -1)
            clickedItem.y = clickedItem.y+thumbnailliftup

        // We use the current{Index,Item} to get the actual view item (not possible otherwise as far as I know)
        view.currentIndex = pos
        clickedIndex = pos
        clickedItem = view.currentItem

        // Ensure new item is lifted up
        if(pos !== -1 && pos != hoveredIndex)
            clickedItem.y = clickedItem.y-thumbnailliftup

        // Update quickinfo (position, filename)
        quickInfo.updateQuickInfo(pos, totalNumberImages, imageUrl);

    }

    function getCenterPos() {
        return (view.contentX+(view.width/2))/(settings.value("Thumbnail/ThumbnailSize")*1)
    }

    // Load next image
    function nextImage() {
        if(clickedIndex+1 < totalNumberImages) {
            displayImage(clickedIndex+1);
            scrollTimer.restart()
        }
    }

    // Load previous image
    function previousImage() {
        if(clickedIndex-1 >= 0) {
            displayImage(clickedIndex-1)
            scrollTimer.restart()
        }
    }

    // Load proper thumbnail at position 'pos' (smart == true means: ONLY IF IT EXISTS)
    function reloadImage(pos, smart) {
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
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            // Item in the center of the screen
            var centerpos = (view.contentX+view.width/2)/(settings.value("Thumbnail/ThumbnailSize")*1)
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

    // View containing all the thumbnails
    ListView {

        id: view

        // Fix size
        anchors.fill: parent

        // No bouncing past ends
        boundsBehavior: Flickable.StopAtBounds

        // Set model
        model:  ListModel {
            id: imageModel
            objectName: "model"
        }

        // Set delegate
        delegate: viewDelegate

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

    // Load the right delegate depending on 'pre' or not 'pre'
    Component {
        id: viewDelegate
        Loader {
            property string _imageUrl: imageUrl
            property bool _smart: smart
            property int _counter: counter
            sourceComponent: pre ? emptyDelegate : imageDelegate
        }
    }

    // Preload delegate (rectangle with filename)
    Component {

        id: emptyDelegate

        Rectangle {

            id: img
            objectName: "emptyDelegate"

            // Store some values...
            property int thumbnailsize: settings.value("Thumbnail/ThumbnailSize")*1
            property int thumbnailliftup: settings.value("Thumbnail/ThumbnailLiftUp")*1

            // ... and some properties
            property var count: _counter
            property var path: _imageUrl

            // Set position
            x: 0
            y: thumbnailbarheight_addon-5

            // Adjust size
            width: thumbnailsize
            height: thumbnailsize

            // Add border
            border.color: "black"
            border.width: 1

            // Set background color to half-transparent
            color: "#88000000"

            Text {

                x: 7
                y: 7

                width: parent.width-14
                height: parent.height-14

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: "white"
                wrapMode: Text.WrapAnywhere
                font.bold: true
                font.pointSize: settings.value("Thumbnail/ThumbnailFontSize")*1

                // Set filename
                property var p: _imageUrl.split("/")
                text: p[p.length-1]

            }

            MouseArea {

                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true

                // Lift item up on hover
                onEntered: {
                    hoveredIndex = img.count
                    if(img.count != clickedIndex)
                        img.y = img.y-thumbnailliftup;
                }
                // Remove item lift when leaving it
                onExited: {
                    hoveredIndex = -1
                    if(clickedIndex != img.count)
                        img.y = img.y+thumbnailliftup;
                }
                // Load thumbnail as main image
                onClicked: {
                    if(clickedIndex != hoveredIndex) {
                        displayImage(hoveredIndex)
                    }
                }
            }
        }
    }

    Component {

        id: imageDelegate

        Rectangle {

            id: imgrect

            property int thumbnailsize: settings.value("Thumbnail/ThumbnailSize")*1
            property int thumbnailliftup: settings.value("Thumbnail/ThumbnailLiftUp")*1
            property int thumbnailspacing: settings.value("Thumbnail/ThumbnailSpacingBetween")*1

            property var count: _counter
            property var path: _imageUrl

            x: 0
            y: thumbnailbarheight_addon-5

            width: thumbnailsize
            height: thumbnailsize

            color: "#88000000"

            border.color: "#BB000000"
            border.width: 1

            Image {

                id: img

                sourceSize: Qt.size(thumbnailsize,thumbnailsize)

                // Set image source (preload or normal) and displayed source dimension
                source: "image://thumb/" + (_smart ? "__**_smart" : "") + _imageUrl

                // Set position
                x: thumbnailspacing/2
                y: thumbnailspacing/2

                // Adjust size
                width: parent.width-thumbnailspacing
                height: parent.height-thumbnailspacing

                fillMode: Image.PreserveAspectFit
                cache: false
                asynchronous: true

                MouseArea {

                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true

                    // Lift item up on hover
                    onEntered: {
                        hoveredIndex = imgrect.count
                        if(imgrect.count != clickedIndex)
                            imgrect.y = imgrect.y-thumbnailliftup;
                    }
                    // Remove item lift when leaving it
                    onExited: {
                        hoveredIndex = -1
                        if(clickedIndex != imgrect.count)
                            imgrect.y = imgrect.y+thumbnailliftup;
                    }
                    // Load thumbnail as main image
                    onClicked: {
                        if(clickedIndex != hoveredIndex) {
                            displayImage(hoveredIndex)
                        }
                    }
                }

                // Catch 'loading completed' of thumbnail
                onStatusChanged: {
                    // If image is ready and it's not a preload image
                    if(img.status == Image.Ready) {
                        // A size of (1,1) means, the image was smartly loaded and didn't exist yet -> re-set preload thumbnail
                        if(img.sourceSize == Qt.size(1,1)) {
                            didntLoadThisThumbnail(_counter);
                            imageModel.set(counter,{"imageUrl" : _imageUrl, "counter" : _counter, "pre" : true, "smart" : false})
                        } else {
                            // Start timer to commit thumbnail database
                            timerhiddenImageCommitDatabase.restart()
                            loadMoreThumbnails();
                        }
                    }
                }
            }

            // Filename label
            Rectangle {

                x: 5
                y: parent.height*0.67

                color: "#88000000"

                width: parent.width-10
                height: childrenRect.height+4

                Text {

                    x: 2
                    y: 2

                    width: parent.width-4

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    color: "white"
                    font.bold: true
                    font.pointSize: settings.value("Thumbnail/ThumbnailFontSize")*1
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 1
                    elide: Text.ElideRight

                    property var p: _imageUrl.split("/")
                    text: p[p.length-1]

                }
            }
        }
    }
}
