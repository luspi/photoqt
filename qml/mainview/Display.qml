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

}
