/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/
pragma ComponentBehavior: Bound

import QtQuick
import PQCScriptsFilesPaths
import PQCScriptsImages
import org.photoqt.qml

Image {

    id: image

    property string imageSource: ""
    onImageSourceChanged: {
        if(imageSource === "") {
            image.source = ""
        } else if(imageSource.includes("::PDF::")) {
            image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(imageSource.split("::PDF::")[1])) // qmllint disable unqualified
        } else {
            image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(imageSource))
        }
    }

    source: ""

    Component.onCompleted: {
        if(image.imageSource.includes("::PDF::"))
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(image.imageSource) // qmllint disable unqualified
        else
            source = "image://full/%1::PDF::%2".arg(currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource))
    }

    asynchronous: true
    cache: false

    property bool noInterpThreshold: sourceSize.width < PQCSettings.imageviewInterpolationThreshold && sourceSize.height < PQCSettings.imageviewInterpolationThreshold

    smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold
    mipmap: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold

    onVisibleChanged: {
        if(!image.visible)
            currentPage = 0
    }

    fillMode: Image.Pad

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        loader_top.imageMirrorH = myMirrorH // qmllint disable unqualified
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV // qmllint disable unqualified

    Connections {
        target: image_wrapper // qmllint disable unqualified
        function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
            image.setMirrorHV(mirH, mirV)
        }
    }

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    Connections {
        target: image_top // qmllint disable unqualified
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
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: image.myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        },
        Rotation {
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        }
    ]

    // with a short delay we load a version of the image scaled to screen dimensions
    Timer {
        id: loadScaledDown
        // this ensures it happens after the animation has stopped
        interval: (PQCSettings.imageviewAnimationDuration+1)*100 // qmllint disable unqualified
        onTriggered: {
            if(loader_top.isMainImage) { // qmllint disable unqualified
                image.screenW = image_top.width
                image.screenH = image_top.height
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
            image.screenW = image_top.width // qmllint disable unqualified
            image.screenH = image_top.height
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
            smooth: image_wrapper.scale < 0.95*loader_top.defaultScale // qmllint disable unqualified
            mipmap: smooth
            visible: loader_top.defaultScale >= image_wrapper.scale // qmllint disable unqualified
            sourceSize: Qt.size(image.screenW, image.screenH)
        }
    }

    property int currentPage: 0
    property int pageCount: PQCScriptsImages.getDocumentPageCount(image.imageSource) // qmllint disable unqualified

    onCurrentPageChanged: {
        PQCConstants.currentFileInsideNum = currentPage
        loadNewPage.restart()
    }

    onPageCountChanged: {
        PQCConstants.currentFileInsideTotal = pageCount // qmllint disable unqualified
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
                if(image.imageSource.includes("::PDF::")) {
                    image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource.split("::PDF::")[1])) // qmllint disable unqualified
                } else {
                    image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource))
                }
                image.asynchronous = true
            }
        }
    }

    onStatusChanged: {
        image_wrapper.status = status // qmllint disable unqualified
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
        else if(status == Image.Ready) {
            if(loader_top.defaultScale < 0.95)
                loadScaledDown.restart()
        }
    }

    onSourceSizeChanged: {
        loader_top.imageResolution = sourceSize // qmllint disable unqualified
        loader_top.resetToDefaults()
        image_wrapper.startupScale = false
    }

    Connections {

        target: PQCNotify

        function onCurrentDocumentJump(leftright : int) {
            loadNewPage.interval = 0
            image.currentPage = (image.currentPage+leftright+image.pageCount)%image.pageCount
        }

    }

    PQDocumentControls {
        id: controls
    }

}
