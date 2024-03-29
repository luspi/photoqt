import QtQuick

import PQCScriptsFilesPaths
import PQCScriptsImages

import "../components"

Image {

    id: image

    source: ""

    Component.onCompleted: {
        if(deleg.imageSource.includes("::PDF::"))
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)
        else
            source = "image://full/%1::PDF::%2".arg(currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource))
    }

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: interpThreshold
    mipmap: interpThreshold

    property bool fitImage: (PQCSettings.imageviewFitInWindow && image.sourceSize.width < deleg.width && image.sourceSize.height < deleg.height)

    width: fitImage ? deleg.width : undefined
    height: fitImage ? deleg.height : undefined

    onVisibleChanged: {
        if(!image.visible)
            currentPage = 0
    }

    fillMode: fitImage ? Image.PreserveAspectFit : Image.Pad

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        deleg.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        deleg.imageMirrorV = myMirrorV

    Connections {
        target: image_top
        function onMirrorH() {
            image.myMirrorH = !image.myMirrorH
        }
        function onMirrorV() {
            image.myMirrorV = !image.myMirrorV
        }
        function onMirrorReset() {
            image.myMirrorH = false
            image.myMirrorV = false
        }
        function onWidthChanged() {
            resetScreenSize.restart()
        }
        function onHeightChanged() {
            resetScreenSize.restart()
        }
    }

    transform: [
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    // with a short delay we load a version of the image scaled to screen dimensions
    Timer {
        id: loadScaledDown
        interval: (PQCSettings.imageviewAnimationDuration+1)*100    // this ensures it happens after the animation has stopped
        onTriggered: {
            if(deleg.shouldBeShown) {
                screenW = image_top.width
                screenH = image_top.height
                ldl.active = true
            }
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
            smooth: image_wrapper.scale < 0.95*deleg.defaultScale
            mipmap: smooth
            visible: deleg.defaultScale >= image_wrapper.scale
            sourceSize: Qt.size(screenW, screenH)
        }
    }

    property int currentPage: 0
    property int pageCount: PQCScriptsImages.getDocumentPageCount(deleg.imageSource)

    onCurrentPageChanged: {
        loadNewPage.restart()
    }

    Timer {
        id: loadNewPage
        interval: 200
        onTriggered: {
            interval = 200
            if(controls.pressed) {
                loadNewPage.restart()
            } else {
                image.asynchronous = false
                if(deleg.imageSource.includes("::PDF::")) {
                    image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(deleg.imageSource.split("::PDF::")[1]))
                } else {
                    image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(deleg.imageSource))
                }
                image.asynchronous = true
            }
        }
    }

    onWidthChanged: {
        image_wrapper.width = width
        deleg.resetToDefaults()
        image_wrapper.startupScale = false
    }
    onHeightChanged: {
        image_wrapper.height = height
        deleg.resetToDefaults()
        image_wrapper.startupScale = false
    }

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
        else if(status == Image.Ready) {
            if(deleg.defaultScale < 0.95)
                loadScaledDown.restart()
        }
    }

    onSourceSizeChanged: {
        deleg.imageResolution = sourceSize
        deleg.resetToDefaults()
        image_wrapper.startupScale = false
    }

    Connections {

        target: image_top

        function onDocumentJump(leftright) {
            loadNewPage.interval = 0
            image.currentPage = (image.currentPage+leftright+image.pageCount)%image.pageCount
        }

    }

    PQDocumentControls {
        id: controls
    }

}
