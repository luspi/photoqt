import QtQuick 2.6
import "../elements"

Item {

    id: top

    // The position of the bar, either at top or bottom
    x: 0
    y: settings.thumbnailposition=="Top" ? 0 : mainwindow.height-height
    width: mainwindow.width
    height: settings.thumbnailsize+settings.thumbnailLiftUp+25

    // Bar hidden/shown
    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: 200 } }

    // Some properties about the current folder
    property string path: ""
    property var allFiles: []
    property int totalNumberImagesInFolder: 0

    // The index of the currently displayed image
    property int currentPos: 0
    onCurrentPosChanged: {
        // Update the view to make sure the current image is visible
        if(safeToUsePosWithoutCrash)
            _ensureCurrentItemVisible()
    }

    // If we call _ensureCurrentItemVisible() immediately, then PhotoQt is likely to crash as the ListView hasn't finished setting up yet.
    // This timer provides a small yet sufficient buffer to ensure everything is ready to go before ensuring the view is positioned properly
    property bool safeToUsePosWithoutCrash: false
    Timer {
        id: safeToUsePosWithoutCrash_TIMER
        repeat: false
        interval: 250
        onTriggered: {
            safeToUsePosWithoutCrash = true
            _ensureCurrentItemVisible()
        }
    }

    // Enable moving of flickable with mouse wheel (i.e., translate vertical to horizontal scroll)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onWheel: {
            verboseMessage("ThumbnailBar.MouseArea::onWheel", wheel.angleDelta)
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

        id: centerview

        // Centered!
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: (allFiles.length*settings.thumbnailsize > parent.width ? 0 : (parent.width-allFiles.length*settings.thumbnailsize)/2)
        width: (allFiles.length*settings.thumbnailsize > parent.width ? parent.width : allFiles.length*settings.thumbnailsize)

        ListView {

            id: view

            // Same dimensions as parent element
            anchors.fill: parent

            // No bouncing past ends
            boundsBehavior: Flickable.DragAndOvershootBounds

            // Set model
            model:  ListModel {
                id: imageModel
                objectName: "model"
            }

            // Set delegate
            delegate: viewcontainer

            // Turn it horizontal
            orientation: ListView.Horizontal

            // A scrollbar indicating the position along the bar
            ScrollBarHorizontal {
                id: scrollbar
                visible: !settings.thumbnailDisable && (view.contentWidth > view.width)
                flickable: view;
                displayAtBottomEdge: settings.thumbnailposition=="Bottom"
            }

        }

    }


    Component {

        id: viewcontainer

        Rectangle {

            id: rect

            // Some extra margin for visual improvements
            property int thumbnailExtraMargin: 25

            // activated is the image that is currently hovered by the mouse
            property bool activated: false

            // loaded is the image currently loaded
            property bool loaded: imagePath==variables.currentFile

            // React to change in current file to see if this image is the loaded one
            Connections {
                target: variables
                onCurrentFileChanged:
                    loaded = (imagePath==variables.currentFile)
            }

            // The color behind the thumbnail
            color: colour.thumbnails_bg

            // The width and the height of the rectangle depends on the thumbnailsize (plus a little extra in height)
            width: settings.thumbnailsize
            height: settings.thumbnailsize+settings.thumbnailLiftUp+rect.thumbnailExtraMargin

            // Update the position of the current thumbnail depending on the activated, loaded and edge setting
            y: activated||loaded
                    ? (settings.thumbnailposition=="Top"
                            ? -rect.thumbnailExtraMargin/2+settings.thumbnailLiftUp
                            : 0)+rect.thumbnailExtraMargin/3
                    : (settings.thumbnailposition=="Top"
                            ? -rect.thumbnailExtraMargin/2
                            : settings.thumbnailLiftUp)+rect.thumbnailExtraMargin/3

            // Make sure the currentPos int always follows the loaded image
            onLoadedChanged:
                if(loaded) currentPos = index


            // The thumbnail image
            Image {

                id: img

                // The positioning of the thumbnail inside of the containing rectangle
                anchors {
                    fill: parent
                    leftMargin: settings.thumbnailSpacingBetween
                    rightMargin: settings.thumbnailSpacingBetween
                    topMargin: settings.thumbnailposition=="Top" ? settings.thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3) : undefined
                    bottomMargin: settings.thumbnailposition=="Top" ? undefined : settings.thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3)
                }

                // Animate lift up/down of thumbnails
                Behavior on anchors.bottomMargin { NumberAnimation { duration: 100 } }
                Behavior on anchors.topMargin { NumberAnimation { duration: 100 } }

                // Set proper fill mode
                fillMode: Image.PreserveAspectFit

                // always load them assynchronously
                asynchronous: true

                // Set the source based on the special imageloader
                source: "image://thumb/" + imagePath

            }

            // The mouse area for the thumbnail also holds a tooltip
            ToolTip {

                anchors.fill: parent

                // set cursor shape
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                // The tooltip is the current image filename
                text: getanddostuff.removePathFromFilename(imagePath)

                // set lift up/down of thumbnails
                onEntered:
                    rect.activated = true
                onExited:
                    rect.activated = false

                // Load the selected thumbnail as main image
                onClicked: {
                    variables.currentFile = imagePath
                    imageitem.loadImage("image://full/" + imagePath)
                }
            }

            // Filename label (when filename-only NOT enabled)
            Rectangle {

                // The location and dimension of the label
                x: 5
                y: settings.thumbnailposition=="Top" ? parent.height*0.45 : parent.height*0.55
                width: parent.width-10
                height: childrenRect.height+4

                // Visibility depends on settings
                visible: !settings.thumbnailFilenameInstead && settings.thumbnailWriteFilename

                // The color of the rectangle behind the text
                color: colour.thumbnails_filename_bg

                // The actual filename
                Text {

                    // Location and width. Height is always one line
                    x: 2
                    y: 2
                    width: parent.width-4

                    // Visibility depends on settings
                    visible: !settings.thumbnailFilenameInstead && settings.thumbnailWriteFilename

                    // center label vertiucally and horizontally
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    // The appearance of the text
                    color: colour.text
                    font.bold: true
                    font.pointSize: settings.thumbnailFontSize

                    // The handling of the text (in particular too long texts)
                    maximumLineCount: 1
                    elide: Text.ElideRight

                    // Set the tooltip
                    text: getanddostuff.removePathFromFilename(imagePath)

                }
            }

        }

    }

    // React to signals from caller, way for other elements to interact with the thumbnail bar
    Connections {
        target: call
        onThumbnailsShow:
            show()
        onThumbnailsHide:
            hide()
        onThumbnailsLoadDirectory:
            loadDirectory(filename, filter)
        onLoadNext:
            nextImage()
        onLoadPrev:
            prevImage()
    }


    // Ensure selected item is centered/visible
    function _ensureCurrentItemVisible() {

        if(totalNumberImagesInFolder*settings.thumbnailsize > top.width) {

            // Newly loaded dir => center item
            if(settings.thumbnailCenterActive) {
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

        verboseMessage("ThumbnailBar::positionViewAtIndex()", index + " - " + loc)
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


    // Load the specified directory based on the specified filter
    function loadDirectory(filename, filter) {

        // When loading a directory, we can only call positionViewAtIndex after a few ms
        safeToUsePosWithoutCrash = false

        // Clear the current image model
        imageModel.clear()

        // Get the properties of the current folder
        path = getanddostuff.removeFilenameFromPath(filename)
        allFiles = getanddostuff.getFilesIn(path)
        totalNumberImagesInFolder = allFiles.length

        // Set the starting position
        currentPos = allFiles.indexOf(getanddostuff.removePathFromFilename(filename))

        // Load the image (based on the current filter). If no filter is set, we can avoid the expensive if-statement inside the loop
        if(filter == "") {
            for(var i = 0; i < totalNumberImagesInFolder; ++i)
                    imageModel.append({"imagePath" : path + "/" + allFiles[i]})
        } else {
            for(var i = 0; i < totalNumberImagesInFolder; ++i) {
                if(allFiles[i].indexOf(filter) >= 0)
                    imageModel.append({"imagePath" : path + "/" + allFiles[i]})
            }
        }

        // Start the timer after which it is assumed to be saved to call positionViewAtIndex
        safeToUsePosWithoutCrash_TIMER.running = true

    }

    // Show the thumbnail bar
    function show() {
        opacity = 1
    }

    // Hide the thumbnail bar
    function hide() {
        opacity = 0
    }

    // Load the next image in the folder
    function nextImage() {
        // We need to use a temp variable, otherwise wrapping the end of the images around to the beginning wont work!
        var loadpos = currentPos
        if(loadpos == allFiles.length-1)
            loadpos = 0
        else
            loadpos += 1
        variables.currentFile = path + "/" + allFiles[loadpos]
        imageitem.loadImage("image://full/" + variables.currentFile)
        currentPos = loadpos
    }

    // Load the previous image in the folder
    function prevImage() {
        // We need to use a temp variable, otherwise wrapping the beginning of the images around to the end wont work!
        var loadpos = currentPos
        if(loadpos <= 0)
            loadpos = allFiles.length-1
        else
            loadpos -= 1
        variables.currentFile = path + "/" + allFiles[loadpos]
        imageitem.loadImage("image://full/" + path + "/" + allFiles[currentPos])
        currentPos = loadpos
    }

}
