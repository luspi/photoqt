import QtQuick 2.4

Rectangle {

    id: rect;

    // some general settings
    anchors.fill: parent
    color: "transparent"

    // this will be set to the id in SmartImage.qml
    property string name: ""

    // the source of the image currently set to this item
    property string source: ""
    onSourceChanged: handleNewSource()

    property bool animated: false

    // Simulate the image status property
    property int status: Image.Null
    onStatusChanged: {

        if(source == "") return

        if(status == Image.Ready) {
            makeImageVisible(name)
            // if it's an animation, start the animation timer
            if(!animated)
                img_mask.showMaskImage()
            loading_rect.hideLoader()
            lastModified = getanddostuff.getLastModified(source)
        } else
            loading_rect.showLoader()

    }

    // the time the current image was last modified
    property string lastModified: ""

    // The opacity property
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: _fadeDurationNextImage; } }
    onOpacityChanged: {
        if(opacity == 1) {
            _fadeDurationNextImage = fadeduration
            if(!animated)
                img_mask.showMaskImage()
        } else if(opacity == 0) {
            img_mask.hideMaskImage()
        }
    }

    // This is the main image, used most of the time!
    Image {
        id: normalimg
        anchors.fill: parent
        cache: true
        mipmap: true
        source: "image://empty/" + rect_top.width + "x" + rect_top.height
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        visible: true
        mirror: false
        onStatusChanged: {
            rect.status = status
            if(status == Image.Ready) {
                normalimg.visible = true
                animimg.visible = false
            }
        }
    }

    // only used when animation present. With each frame, PhotoQt swaps image item back and forth to ensure no flickering
    AnimatedImage {
        id: animimg
        anchors.fill: parent
        cache: true
        mipmap: true
        source: "qrc://img/empty.png"
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        mirror: false
        visible: false
        onStatusChanged: {
            rect.status = status
            if(status == Image.Ready) {
                normalimg.visible = false
                animimg.visible = true
            }
        }
    }

    // Stop animation timer
    function stopAnimation() {
        animimg.paused = true
    }
    // restart animation timer, if animation is present
    function restartAnimation() {
        if(animated)
            animimg.paused = false
    }

    // This item is only displayed if the image is not scaled but biger than the screen.
    // It shows a scaled-to-screen-size version of the image for better display quality.
    Image {
        id: img_mask
        anchors.fill: parent
        mipmap: true
        cache: false
        mirror: false
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        opacity: 1
        // we need to remove image if element is hidden, otherwise there will be an artefact when switching images
        onOpacityChanged: if(opacity == 0) hideMaskImage()
        // this line is important, setting the sourceSize
        sourceSize: Qt.size(rect_top.width, rect_top.height)
        visible: imgrect.scale <= 1 && source != "" && (getSourceSize().width > flick.width || getSourceSize().height > flick.height)
        function showMaskImage() {
            source = parent.source
        }
        function hideMaskImage() {
            source = ""
        }
    }

    // handle new source filename
    function handleNewSource() {
        animimg.source = ""
        animimg.paused = false
        animated = getanddostuff.isImageAnimated(source)
        if(!animated) {
            normalimg.source = source
            animimg.source = ""
        } else {
            var angle = 0
            if(source.indexOf("::photoqt::") != -1) {
                angle = source.split("::photoqt::")[1].split("::")[0];
                source = source.split("::photoqt")[0]
            }
            if(source.indexOf("image://full/") != -1)
                source = "file:/" + source.split("image://full/")[1]

            normalimg.source = ""
            animimg.rotation = angle
            animimg.source = source
        }
    }

    // return the image source size
    function getSourceSize() {
        if(!animated)
            return normalimg.sourceSize
        return animimg.sourceSize
    }

    // set a fillmode to the images here
    function setFillMode(mode) {
        normalimg.fillMode = mode
        animimg.fillMode = mode
        img_mask.fillMode = mode
    }

    // set the mirror property
    function setMirror(mirr) {
        normalimg.mirror = mirr
        animimg.mirror = mirr
        img_mask.mirror = mirr
    }

    // get the mirror property (same on all three elements)
    function getMirror() {
        return normalimg.mirror
    }

    // get the dimensions of the image actually displayed
    function getActualPaintedImageSize() {
        if(!animated)
            return Qt.size(normalimg.paintedWidth, normalimg.paintedHeight)
        return /*animimg.rotation%180==90 ? Qt.size(animimg.paintedHeight, animimg.paintedWidth) : */Qt.size(animimg.paintedWidth, animimg.paintedHeight)
    }

    function playPauseAnimation() {
        var cur = animimg.paused
        animimg.paused = !cur
    }

    function setRotation(angle) {
        animimg.rotation = angle
    }

    //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    //
    // When an element is shown on top of the mainview, we interrupt an animation while they are visible
    //

    Connections {
        target: openfile
        onOpacityChanged: {
            if(openfile.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: settingsmanager
        onOpacityChanged: {
            if(settingsmanager.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: about
        onOpacityChanged: {
            if(about.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: wallpaper
        onOpacityChanged: {
            if(wallpaper.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: scaleImage
        onOpacityChanged: {
            if(scaleImage.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: filter
        onOpacityChanged: {
            if(filter.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: rename
        onOpacityChanged: {
            if(rename.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: slideshow
        onOpacityChanged: {
            if(slideshow.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }
    Connections {
        target: startup
        onOpacityChanged: {
            if(startup.opacity >= 0.5) stopAnimation()
            else restartAnimation()
        }
    }

}
