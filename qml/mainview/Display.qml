import QtQuick 2.4
import QtQuick.Controls 1.3

import "../elements"

Item {

    id: item

    property int scaleSpeed: 40

    function setAnimatedImage(path) {
        var s = getstuff.getImageSize(path)
        if(s.width  < normal.width && s.height < normal.height) {
            normal.fillMode = Image.Pad
            animated.fillMode = Image.Pad
        } else {
            normal.fillMode = Image.PreserveAspectFit
            animated.fillMode = Image.PreserveAspectFit
        }

        normal.width = item.width
        normal.height = item.height
        animated.width = item.width
        animated.height = item.height

        animated.visible = true
        normal.visible = false
        animated.source = path
        normal.source = ""
        metaData.setData(getmetadata.getExiv2(path))
    }
    function setNormalImage(path) {
        var s = getstuff.getImageSize(path)
        if(s.width  < normal.width && s.height < normal.height) {
            normal.fillMode = Image.Pad
            animated.fillMode = Image.Pad
        } else {
            normal.fillMode = Image.PreserveAspectFit
            animated.fillMode = Image.PreserveAspectFit
        }

        normal.width = item.width
        normal.height = item.height
        animated.width = item.width
        animated.height = item.height

        animated.visible = false
        normal.visible = true
        animated.source = ""
        normal.source = path
        metaData.setData(getmetadata.getExiv2(path))
    }

    function setSourceSize(w,h) {
        animated.sourceSize.width = w
        animated.sourceSize.height = h
        normal.sourceSize.width = w
        normal.sourceSize.height = h
    }

    Flickable {

        id: flickArea

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        contentHeight: normal.height*normal.scale
        contentWidth: normal.width*normal.scale

        width: contentWidth < parent.width ? contentWidth : parent.width
        height: contentHeight < parent.height ? contentHeight : parent.height

        Image {

            id: normal

            width: item.width
            height: item.height

            fillMode: Image.PreserveAspectFit
            asynchronous: false

            transformOrigin: Item.TopLeft

            MouseArea {

                anchors.fill: parent

                onWheel: doScaling(normal,wheel.angleDelta)

            }

        }

        AnimatedImage {

            id: animated

            width: item.width
            height: item.height

            fillMode: Image.PreserveAspectFit
            asynchronous: false

            transformOrigin: Item.TopLeft

            MouseArea {

                anchors.fill: parent

                onWheel: doScaling(animated, wheel.angleDelta)

            }


        }

    }

    ScrollBarHorizontal { flickable: flickArea; }
    ScrollBarVertical { flickable: flickArea; }

    function doScaling(it, delta) {
        it.scale *= (delta.y < 0 ? 1.05 : 1/1.05)

        var newx;
        var newy;

        if(it.scale*item.width > item.width && it.scale*item.height > item.height) {

            var cursorpos = getstuff.getCursorPos()

            newx = cursorpos.x/it.scale-(cursorpos.x/item.width)*flickArea.contentItem.width
            newy = cursorpos.y/it.scale-(cursorpos.y/item.height)*flickArea.contentItem.height

            if(it.scale*item.width > item.width) {
                flickArea.contentItem.x = newx
            }

            if(it.scale*item.height > item.height) {
                flickArea.contentItem.y = newy
            }

        } else {
            flickArea.contentItem.x = 0
            flickArea.contentItem.y = 0
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
