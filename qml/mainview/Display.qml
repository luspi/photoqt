import QtQuick 2.3

Item {

    function setAnimatedImage(path) {
        var s = getimageinfo.getImageSize(path)
        if(s.width  < normal.width && s.height < normal.height) {
            normal.fillMode = Image.Pad
            animated.fillMode = Image.Pad
        } else {
            normal.fillMode = Image.PreserveAspectFit
            animated.fillMode = Image.PreserveAspectFit
        }
        animated.visible = true
        normal.visible = false
        animated.source = path
        normal.source = ""
        metaData.setData(getmetadata.getExiv2(path))
    }
    function setNormalImage(path) {
        var s = getimageinfo.getImageSize(path)
        if(s.width  < normal.width && s.height < normal.height) {
            normal.fillMode = Image.Pad
            animated.fillMode = Image.Pad
        } else {
            normal.fillMode = Image.PreserveAspectFit
            animated.fillMode = Image.PreserveAspectFit
        }

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

    AnimatedImage {

        id: animated

        anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        asynchronous: false
        clip: true

    }

    Image {

        id: normal

        anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        asynchronous: false
        clip: true

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
