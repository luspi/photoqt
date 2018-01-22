import QtQuick 2.5
import QtGraphicalEffects 1.0
import "../elements"
import "../loadfile.js" as Load

Item {

    id: top

    property int thumbnailSize: Math.max(20, Math.min(256, settings.thumbnailSize))
    property int thumbnailPosition: settings.thumbnailPosition=="Top" ? "Top" : "Bottom"
    property int thumbnailSpacingBetween: Math.max(0, Math.min(30, settings.thumbnailSpacingBetween))
    property int thumbnailLiftUp: Math.max(0, Math.min(40, settings.thumbnailLiftUp))

    // The position of the bar, either at top or bottom
    x: metadata.nonFloatWidth
    y: thumbnailPosition=="Top" ? 0 : mainwindow.height-height
    width: mainwindow.width-metadata.nonFloatWidth
    height: thumbnailSize+thumbnailLiftUp+25

    Behavior on x { NumberAnimation { duration: variables.animationSpeed } }
    Behavior on width { NumberAnimation { duration: variables.animationSpeed } }

    // Bar hidden/shown
    opacity: 0
    visible: (opacity!=0)
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    clip: true

    // The index of the currently displayed image is handled in Variables
    Connections {
        target: variables
        onCurrentFilePosChanged: {
            if(safeToUsePosWithoutCrash) {
                _ensureCurrentItemVisible()
            }
        }
        onGuiBlockedChanged: {
            if(variables.guiBlocked && top.opacity == 1)
                top.opacity = 0.2
            else if(!variables.guiBlocked && top.opacity == 0.2)
                top.opacity = 1
        }
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

    property bool mouseHoveringThumbnails: false

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
        onEntered:
            mouseHoveringThumbnails = true
        onExited:
            mouseHoveringThumbnails = false
    }

    // This item make sure, that the thumbnails are displayed centered when their combined width is less than the width of the screen
    Item {

        id: centerview

        // Centered!
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: (variables.allFilesCurrentDir.length*thumbnailSize > parent.width
            ? 0
            : (parent.width-variables.allFilesCurrentDir.length*thumbnailSize)/2)
        width: (variables.allFilesCurrentDir.length*thumbnailSize > parent.width
                ? parent.width
                : variables.allFilesCurrentDir.length*thumbnailSize)

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
                displayAtBottomEdge: thumbnailPosition=="Bottom"
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
            property bool loaded: false

            // React to change in current file to see if this image is the loaded one
            Connections {
                target: variables
                onCurrentFileChanged:
                    loaded = (getanddostuff.removePathFromFilename(imagePath)==variables.currentFile)
            }

            Component.onCompleted:
                loaded = (getanddostuff.removePathFromFilename(imagePath)==variables.currentFile)

            // The color behind the thumbnail
            color: colour.thumbnails_bg

            // The width and the height of the rectangle depends on the thumbnailsize (plus a little extra in height)
            width: thumbnailSize
            height: thumbnailSize+thumbnailLiftUp+rect.thumbnailExtraMargin

            // Update the position of the current thumbnail depending on the activated, loaded and edge setting
            y: activated||loaded
                    ? (thumbnailPosition=="Top"
                            ? -rect.thumbnailExtraMargin/2+thumbnailLiftUp
                            : 0)+rect.thumbnailExtraMargin/3
                    : (thumbnailPosition=="Top"
                            ? -rect.thumbnailExtraMargin/2
                            : thumbnailLiftUp)+rect.thumbnailExtraMargin/3

            Behavior on y { NumberAnimation { duration: variables.animationSpeed/5 } }

            // The thumbnail image
            Image {

                id: img

                // The positioning of the thumbnail inside of the containing rectangle
                anchors {
                    fill: parent
                    leftMargin: thumbnailSpacingBetween
                    rightMargin: thumbnailSpacingBetween
                    topMargin: thumbnailPosition=="Top" ? thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3) : undefined
                    bottomMargin: thumbnailPosition=="Top" ? undefined : thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3)
                }

                // Animate lift up/down of thumbnails
                Behavior on anchors.bottomMargin { NumberAnimation { duration: variables.animationSpeed/2 } }
                Behavior on anchors.topMargin { NumberAnimation { duration: variables.animationSpeed/2 } }

                // Set proper fill mode
                fillMode: Image.PreserveAspectFit

                // always load them assynchronously
                asynchronous: true

                // when no thumbnail image is loaded, the icon is shown partially opaque
                opacity: settings.thumbnailFilenameInstead ? 0.6 : (status==Image.Ready ? 1 : 0)
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

                // only if this is true do we show the thumbnail image (value depends on status of loading of mainimage)
                property bool loadThumbnail: true

                // Set the source based on the special imageloader (icon or thumbnail)
                // loading depends on the loadThumbnail property which in turn depends on the mainimage and whether the thumbnail has already finished loading
                source: loadThumbnail ? (settings.thumbnailFilenameInstead ? "image://icon/image-" + getanddostuff.getSuffix(imagePath) : "image://thumb/" + imagePath) : "image://icon/image-" + getanddostuff.getSuffix(imagePath)

                // We react to changes in the status of loading the mainimage
                Connections {
                    target: imageitem
                    onMainImageLoadingChanged:
                        // whether we load a thumbnail depends on whether the mainimage has finished loading OR if the thumbnail has already finished loading
                        img.loadThumbnail = (imageitem.mainImageFinishedLoading||img.status==Image.Ready)
                }

                // When created the mainimage is likely not yet finished loading, this needs to be reflected in the loadThumbnail property
                Component.onCompleted:
                    img.loadThumbnail = imageitem.mainImageFinishedLoading

            }

            // Temporary image icon while thumbnail is loading
            Image {
                anchors.fill: img
                anchors.margins: 10
                verticalAlignment: Image.AlignTop
                source: settings.thumbnailFilenameInstead ? "" : "image://icon/image-" + getanddostuff.getSuffix(imagePath)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: !settings.thumbnailFilenameInstead
                opacity: img.status==Image.Ready ? 0 : 0.8
                Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
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
                onEntered: {
                    rect.activated = true
                    mouseHoveringThumbnails = true
                }
                onExited: {
                    rect.activated = false
                    mouseHoveringThumbnails = false
                }

                // Load the selected thumbnail as main image
                onClicked: {
                    variables.currentFile = getanddostuff.removePathFromFilename(imagePath)
                    Load.loadFile(variables.currentFile, variables.filter, false)
                }
            }

            // Filename label (when filename-only IS enabled)
            Rectangle {

                // The size and location
                anchors {
                    fill: parent
                    leftMargin: thumbnailSpacingBetween
                    rightMargin: thumbnailSpacingBetween
                    topMargin: thumbnailPosition=="Top" ? thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3) : undefined
                    bottomMargin: thumbnailPosition=="Top" ? undefined : thumbnailLiftUp+2*(rect.thumbnailExtraMargin/3)
                }

                // only visible when filename-only thumbnail enabled
                visible: settings.thumbnailFilenameInstead

                // some slight background color, slightly darkened
                color: "#44000000"

                // The filename text
                Text {

                    // size and margin
                    anchors.fill: parent
                    anchors.margins: 10

                    // some styling
                    color: "white"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    font.pointSize: Math.max(5, Math.min(20, settings.thumbnailFilenameInsteadFontSize))
                    font.bold: true

                    // align text
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter

                    // the filename
                    text: getanddostuff.removePathFromFilename(imagePath)

                }

            }

            // Filename label (when filename-only NOT enabled)
            Rectangle {

                // The location and dimension of the label
                x: 5
                y: thumbnailPosition=="Top" ? parent.height*0.45 : parent.height*0.55
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
                    font.pointSize: Math.max(5, Math.min(20, settings.thumbnailFontSize))

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
            loadDirectory()
    }

    Connections {
        target: imageitem
        onZoomChanged: {
            if(imageitem.isZoomedIn() && settings.thumbnailKeepVisibleWhenNotZoomedIn && !mouseHoveringThumbnails)
                hide()
            else if(!imageitem.isZoomedIn() && settings.thumbnailKeepVisibleWhenNotZoomedIn)
                show()
        }
    }


    // Ensure selected item is centered/visible
    function _ensureCurrentItemVisible() {

        if(variables.totalNumberImagesCurrentFolder*thumbnailSize > top.width) {

            // Newly loaded dir => center item
            if(settings.thumbnailCenterActive) {
                verboseMessage("ThumbnailBar::displayImage()","Show thumbnail centered")
                positionViewAtIndex(variables.currentFilePos,ListView.Center)
            } else {
                verboseMessage("ThumbnailBar::displayImage()","Keep thumbnail visible")
                positionViewAtIndex(variables.currentFilePos,ListView.Contain)
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
        if(loc == ListView.Contain && destPos != pos) {
            // Make sure there is a little margin past the thumbnail kept visible
            if(destPos > pos) destPos += thumbnailSize/2
            else if(destPos < pos) destPos -= thumbnailSize/2
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
    function loadDirectory() {

        // When loading a directory, we can only call positionViewAtIndex after a few ms
        safeToUsePosWithoutCrash = false

        // Clear the current image model
        imageModel.clear()

        // Load the images
        for(var i = 0; i < variables.totalNumberImagesCurrentFolder; ++i)
                imageModel.append({"imagePath" : variables.currentDir + "/" + variables.allFilesCurrentDir[i]})

        // Start the timer after which it is assumed to be saved to call positionViewAtIndex
        safeToUsePosWithoutCrash_TIMER.running = true

    }

    // Show the thumbnail bar
    function show() {
        if(variables.filterNoMatch || variables.deleteNothingLeft) return
        opacity = 1
        variables.thumbnailsheight = top.height
    }

    // Hide the thumbnail bar
    function hide() {
        opacity = 0
    }

}
