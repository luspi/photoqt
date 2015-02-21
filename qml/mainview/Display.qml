import QtQuick 2.4
import QtQuick.Controls 1.3

import "../elements"

Item {

    id: item

    // Current image animated?
    property bool animated: false

    // How fast do we zoom in/out
    property real scaleSpeed: 0.1

    // Keep track of where we are in zooming
    property int zoomSteps: 0

    property string url: ""

    property bool zoomTowardsCenter: false

    property bool imageWidthLargerThanHeight: true

    // Set animated image
    function setAnimatedImage(path) {

        resetZoom()
        resetRotation()

        // Pad or Fit?
        var s = getstuff.getImageSize(path)
        if(s.width < item.width && s.height < item.height)
            anim.fillMode = Image.Pad
        else
            anim.fillMode = Image.PreserveAspectFit

        imageWidthLargerThanHeight = (s.width >= s.height);

        // Set source
        anim.source = path
        url = path

        // Animated!!!
        animated = true

        // Update metadata
        metaData.setData(getmetadata.getExiv2(path))

    }

    // Set non animated image
    function setNormalImage(path) {

        resetZoom()
        resetRotation()

        // Pad or Fit?
        var s = getstuff.getImageSize(path)
        if(s.width < item.width && s.height < item.height)
            norm.fillMode = Image.Pad
        else
            norm.fillMode = Image.PreserveAspectFit

        imageWidthLargerThanHeight = (s.width >= s.height);

        // Set source
        norm.source = path
        url = path

        // Animated!!!
        animated = false

        // Update metadata
        metaData.setData(getmetadata.getExiv2(path))

    }

    // Update source sizes
    function setSourceSize(w,h) {
        anim.sourceSize.width = w
        anim.sourceSize.height = h
        norm.sourceSize.width = w
        norm.sourceSize.height = h
    }

    function resetZoom() {

        // Re-set source size to screen size
        if((anim.rotation%180 == 90 || norm.rotation%180 == 90) && imageWidthLargerThanHeight)
            setSourceSize(item.height,item.width)
        else
            setSourceSize(item.width,item.height)

        // Reset scaling
        norm.scale = 1
        anim.scale = 1

        // No more zooming
        zoomSteps = 0
    }

    function resetRotation() {
        norm.rotation = 0
        anim.rotation = 0
        setSourceSize(item.width,item.height)
    }

    function zoomIn(towardsCenter) {
        zoomTowardsCenter = true
        doZoom(true)
    }
    function zoomOut(towardsCenter) {
        zoomTowardsCenter = true
        doZoom(false)
    }

    function rotateRight() {
        if(animated) {
            anim.rotation += 90
            anim.calculateSize()
        } else {
            norm.rotation += 90
            norm.calculateSize()
        }
        if((anim.rotation%180 == 90 || norm.rotation%180 == 90) && imageWidthLargerThanHeight)
            setSourceSize(item.height,item.width)
        else
            setSourceSize(item.width,item.height)
    }

    function rotateLeft() {
        if(animated) {
            anim.rotation -= 90
            anim.calculateSize()
        } else {
            norm.rotation -= 90
            norm.calculateSize()
        }
        if((anim.rotation%180 == 90 || norm.rotation%180 == 90) && imageWidthLargerThanHeight)
            setSourceSize(item.height,item.width)
        else
            setSourceSize(item.width,item.height)
    }

    /****************************************************************************************************
     *
     * Zoom code lines inspired by code at:
     *
     * https://gitorious.org/spena-playground/xmcr/source/87a2bfcb6a1f6688e0ed7169c6b72308ad08778d:src/qml/ZoomableImage.qml
     *
     *****************************************************************************************************/

    Flickable {

        id: flickable
        anchors.fill: parent
        clip: true

        contentHeight: imageContainer.height
        contentWidth: imageContainer.width

        onHeightChanged: animated ? anim.calculateSize() : norm.calculateSize()

        Item {
            id: imageContainer
            width: Math.max((animated ? anim.width : norm.width) * (animated ? anim.scale : norm.scale), flickable.width)
            height: Math.max((animated ? anim.height : norm.height) * (animated ? anim.scale : norm.scale), flickable.height)

            Image {
                id: norm
                visible: !animated
                property real prevScale
                anchors.centerIn: parent
                asynchronous: false
                function calculateSize() {
                    prevScale = Math.min(scale, 1);
                }
                onScaleChanged: {
                    var cursorpos = getstuff.getCursorPos()
                    var x_ratio = (zoomTowardsCenter ? flickable.width/2 : cursorpos.x);
                    var y_ratio = (zoomTowardsCenter ? flickable.height/2 : cursorpos.y);
                    if ((width * scale) > flickable.width) {
                        var xoff = (x_ratio + flickable.contentX) * scale / prevScale;
                        flickable.contentX = xoff - x_ratio;
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (y_ratio + flickable.contentY) * scale / prevScale;
                        flickable.contentY = yoff - y_ratio;
                    }
                    prevScale = scale;
                }
                onStatusChanged: {
                    if (status == Image.Ready) {
                        calculateSize();
                    }
                }
            }

            AnimatedImage {
                id: anim
                visible: animated
                property real prevScale
                anchors.centerIn: parent
                asynchronous: false
                function calculateSize() {
                    prevScale = Math.min(scale, 1);
                }
                onScaleChanged: {
                    var cursorpos = getstuff.getCursorPos()
                    var x_ratio = (zoomTowardsCenter ? flickable.width/2 : cursorpos.x);
                    var y_ratio = (zoomTowardsCenter ? flickable.height/2 : cursorpos.y);
                    if ((width * scale) > flickable.width) {
                        var xoff = (x_ratio + flickable.contentX) * scale / prevScale;
                        flickable.contentX = xoff - x_ratio;
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (y_ratio + flickable.contentY) * scale / prevScale;
                        flickable.contentY = yoff - y_ratio;
                    }
                    prevScale = scale;
                }
                onStatusChanged: {
                    if (status == Image.Ready) {
                        calculateSize();
                    }
                }
            }

            // ZOOM on wheel up/down
            MouseArea {
                anchors.fill: parent
                onWheel: {
                    zoomTowardsCenter = false
                    doZoom(wheel.angleDelta.y > 0)
                }
            }
        }
    }

    function doZoom(zoomin) {

        var s = getstuff.getImageSize(url)

        if(animated) {

            if(zoomin) {

                if(zoomSteps == 0) {
                    anim.sourceSize = undefined
                    if(s.width >= item.width && s.height >= item.height)
                        anim.scale = Math.min(flickable.width / anim.width, flickable.height / anim.height);
                }
                anim.scale += scaleSpeed    // has to come AFTER removing source size!
                zoomSteps += 1

            } else if(!zoomin && (zoomSteps-1)*scaleSpeed+1 > 0) {

                anim.scale -= scaleSpeed  // has to come BEFORE setting source size!
                if(zoomSteps == 1) {
                    anim.sourceSize = Qt.size(item.width,item.height)
                    if(s.width >= item.width && s.height >= item.height)
                        anim.scale = Math.min(flickable.width / anim.width, flickable.height / anim.height);
                }
                zoomSteps -= 1
            }

        } else {

            if(zoomin) {

                if(zoomSteps == 0) {
                    norm.sourceSize = undefined
                    if(s.width >= item.width && s.height >= item.height)
                        norm.scale = Math.min(flickable.width / norm.width, flickable.height / norm.height);
                }
                norm.scale += scaleSpeed    // has to come AFTER removing source size!
                zoomSteps += 1

            } else if(!zoomin && (zoomSteps-1)*scaleSpeed+1 > 0) {

                norm.scale -= scaleSpeed  // has to come BEFORE setting source size!
                if(zoomSteps == 1) {
                    norm.sourceSize = Qt.size(item.width,item.height)
                    if(s.width >= item.width && s.height >= item.height)
                        norm.scale = Math.min(flickable.width / norm.width, flickable.height / norm.height);
                }

                zoomSteps -= 1

            }

        }
    }



    // Rectangle holding the closing x top right
    Rectangle {

        id: rect

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
            onClicked: Qt.quit()
        }

    }

}
