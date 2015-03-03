import QtQuick 2.3
import QtQuick.Controls.Styles 1.2
import QtQuick.Controls 1.2

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

        nofileloaded.visible = false

        resetZoom()
        resetRotation()

        // Pad or Fit?
        var s = getanddostuff.getImageSize(path)
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

        nofileloaded.visible = false

        resetZoom()
        resetRotation()

        // Pad or Fit?
        var s = getanddostuff.getImageSize(path)
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

        id: flickarea
        anchors.fill: parent
        clip: true

        contentHeight: imageContainer.height
        contentWidth: imageContainer.width

        onHeightChanged: animated ? anim.calculateSize() : norm.calculateSize()

        Item {
            id: imageContainer
            width: Math.max((animated ? anim.width : norm.width) * (animated ? anim.scale : norm.scale), flickarea.width)
            height: Math.max((animated ? anim.height : norm.height) * (animated ? anim.scale : norm.scale), flickarea.height)

            Image {
                id: norm
                visible: !animated
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

    ScrollBarHorizontal { flickable: flickarea; }
    ScrollBarVertical { flickable: flickarea; }

    function doZoom(zoomin) {

        // Don't zoom if nothing is loaded
        if(url == "" || blocked) return;

        var s = getanddostuff.getImageSize(url)

        if(animated) {

            if(zoomin) {

                if(zoomSteps == 0) {
                    anim.sourceSize = undefined
                    if(s.width >= item.width && s.height >= item.height)
                        anim.scale = Math.min(flickarea.width / anim.width, flickarea.height / anim.height);
                }
                anim.scale += scaleSpeed    // has to come AFTER removing source size!
                zoomSteps += 1

            } else if(!zoomin && anim.width*anim.scale > item.width*scaleSpeed) {

                anim.scale -= scaleSpeed  // has to come BEFORE setting source size!
                if(zoomSteps == 1) {
                    anim.sourceSize = Qt.size(item.width,item.height)
                    if(s.width >= item.width && s.height >= item.height)
                        anim.scale = Math.min(flickarea.width / anim.width, flickarea.height / anim.height);
                }
                zoomSteps -= 1
            }

        } else {

            if(zoomin) {

                if(zoomSteps == 0) {
                    norm.sourceSize = undefined
                    if(s.width >= item.width && s.height >= item.height)
                        norm.scale = Math.min(flickarea.width / norm.width, flickarea.height / norm.height);
                }
                norm.scale += scaleSpeed    // has to come AFTER removing source size!
                zoomSteps += 1

            } else if(!zoomin && norm.width*norm.scale > item.width*scaleSpeed) {

                norm.scale -= scaleSpeed  // has to come BEFORE setting source size!
                if(zoomSteps == 1) {
                    norm.sourceSize = Qt.size(item.width,item.height)
                    if(s.width >= item.width && s.height >= item.height)
                        norm.scale = Math.min(flickarea.width / norm.width, flickarea.height / norm.height);
                }

                zoomSteps -= 1

            }

        }
    }



    // Rectangle holding the closing x top right
    Rectangle {

        id: rect

        visible: !settings.hidex

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
                if (mouse.button == Qt.RightButton)
                    contextmenuClosingX.popup()
                else
                    Qt.quit()
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

}
