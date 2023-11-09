import QtQuick

import PQCScriptsFilesPaths

AnimatedImage {

    id: image

    asynchronous: true
    source: "file:/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: Math.abs(image_wrapper.scale-1) < 0.1 ? false : interpThreshold
    mipmap: interpThreshold

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onSourceSizeChanged: {
        width = sourceSize.width
        height = sourceSize.height
        image_wrapper.status = Image.Ready
        deleg.imageResolution = sourceSize
    }

    onMirrorChanged:
        deleg.imageMirrorH = mirror
    onMirrorVerticallyChanged:
        deleg.imageMirrorV = image.mirrorVertically

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile

        source: PQCSettings.imageviewTransparencyMarker ? "/other/checkerboard.png" : ""

    }

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

        function onPlayPauseAnimationVideo() {
            image.playing = !image.playing
        }
    }

    function setMirrorHV(mH, mV) {
        image.mirror = mH
        image.mirrorVertically = mV
    }

}
