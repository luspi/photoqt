import QtQuick

import PQCScriptsFilesPaths

Image {

    id: image

    source: "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: Math.abs(image_wrapper.scale-1) < 0.1 ? false : interpThreshold
    mipmap: interpThreshold

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Ready && deleg.defaultScale < 0.95) {
            loadScaledDown.restart()
        }
    }

    onSourceSizeChanged:
        deleg.imageResolution = sourceSize

    Connections {
        target: image_top
        function onMirrorH() {
            image.mirror = !image.mirror
        }
        function onMirrorV() {
            image.mirrorVertically = !image.mirrorVertically
        }
        function onMirrorReset() {
            image.mirror = false
            image.mirrorVertically = false
        }
        function onWidthChanged() {
            resetScreenSize.restart()
        }
        function onHeightChanged() {
            resetScreenSize.restart()
        }

    }

    // with a short delay we load a version of the image scaled to screen dimensions
    Timer {
        id: loadScaledDown
        interval: 250
        onTriggered: {
            screenW = image_top.width
            screenH = image_top.height
            ldl.active = true
        }
    }

    property int screenW
    property int screenH
    Timer {
        id: resetScreenSize
        interval: 500
        repeat: false
        onTriggered: {
            screenW = image_top.width
            screenH = image_top.height
        }
    }

    // image scaled to screen dimensions
    Loader {
        id: ldl
        asynchronous: true
        active: false
        sourceComponent:
        Image {
            width: image.width
            height: image.height
            source: image.source
            visible: deleg.defaultScale >= image_wrapper.scale
            sourceSize: Qt.size(screenW, screenH)
            mirror: image.mirror
            mirrorVertically: image.mirrorVertically
        }
    }

}
