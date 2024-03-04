import QtQuick

import PQCScriptsFilesPaths
import PQCScriptsImages

import "../components"

Image {

    id: image

    source: ""

    Component.onCompleted: {
        if(deleg.imageSource.includes("::ARC::") || currentFile > fileList.length-1)
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(deleg.imageSource)
        else
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::ARC::%2".arg(fileList[currentFile]).arg(deleg.imageSource))
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
            currentFile = 0
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



    property int currentFile: 0
    property var fileList: []
    property int fileCount: fileList.length

    // load the file list asynchronously
    Timer {
        interval: 50
        running: true
        onTriggered: {
            fileList = PQCScriptsImages.listArchiveContent(deleg.imageSource, true)
        }
    }

    onCurrentFileChanged: {
        loadNewFile.restart()
    }

    Timer {
        id: loadNewFile
        interval: 200
        onTriggered: {
            interval = 200
            if(controls.pressed) {
                loadNewFile.restart()
            } else {
                setSource()
            }
        }
    }

    function setSource() {
        var src = deleg.imageSource
        if(src.includes("::ARC::"))
            src = sc.split("::ARC::")[1]
        image.asynchronous = false
        image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::ARC::%2".arg(fileList[currentFile]).arg(src))
        image.asynchronous = true
    }

    onWidthChanged: {
        image_wrapper.width = width
        deleg.resetToDefaults()
    }
    onHeightChanged: {
        image_wrapper.height = height
        deleg.resetToDefaults()
    }

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    onSourceSizeChanged: {
        deleg.imageResolution = sourceSize
        deleg.resetToDefaults()
    }

    Connections {

        target: image_top

        function onArchiveJump(leftright) {
            loadNewFile.interval = 0
            image.currentFile = (image.currentFile+leftright+image.fileCount)%image.fileCount
        }

    }

    PQArchiveControls {
        id: controls
    }

}
