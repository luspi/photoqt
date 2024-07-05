/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick

import PQCScriptsFilesPaths
import PQCScriptsImages

import "../components"

Image {

    id: image

    source: ""

    Component.onCompleted: {
        if(loader_top.imageSource.includes("::PDF::"))
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(loader_top.imageSource)
        else
            source = "image://full/%1::PDF::%2".arg(currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(loader_top.imageSource))
    }

    asynchronous: true
    cache: false

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: interpThreshold
    mipmap: interpThreshold

    property bool fitImage: false

    width: fitImage ? image_top.width : undefined
    height: fitImage ? image_top.height : undefined

    onVisibleChanged: {
        if(!image.visible)
            currentPage = 0
    }

    fillMode: fitImage ? Image.PreserveAspectFit : Image.Pad

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        loader_top.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV

    function setMirrorHV(mH, mV) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

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
            if(loader_top.isMainImage) {
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
            smooth: image_wrapper.scale < 0.95*loader_top.defaultScale
            mipmap: smooth
            visible: loader_top.defaultScale >= image_wrapper.scale
            sourceSize: Qt.size(screenW, screenH)
        }
    }

    property int currentPage: 0
    property int pageCount: PQCScriptsImages.getDocumentPageCount(loader_top.imageSource)

    onCurrentPageChanged: {
        image_top.currentFileInside = currentPage
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
                if(loader_top.imageSource.includes("::PDF::")) {
                    image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(loader_top.imageSource.split("::PDF::")[1]))
                } else {
                    image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(loader_top.imageSource))
                }
                image.asynchronous = true
            }
        }
    }

    onWidthChanged: {
        image_wrapper.width = width
        loader_top.resetToDefaults()
        image_wrapper.startupScale = false
    }
    onHeightChanged: {
        image_wrapper.height = height
        loader_top.resetToDefaults()
        image_wrapper.startupScale = false
    }

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
        else if(status == Image.Ready) {
            fitImage = (PQCSettings.imageviewFitInWindow && image.sourceSize.width < image_top.width && image.sourceSize.height < image_top.height)
            if(loader_top.defaultScale < 0.95)
                loadScaledDown.restart()
        }
    }

    onSourceSizeChanged: {
        loader_top.imageResolution = sourceSize
        loader_top.resetToDefaults()
        image_wrapper.startupScale = false
    }

    Connections {

        target: image_top

        function onDocumentJump(leftright) {
            loadNewPage.interval = 0
            image.currentPage = (image.currentPage+leftright+image.pageCount)%image.pageCount
        }

    }

    Connections {

        target: loader_top

        function onImageSourceChanged() {
            if(loader_top.imageSource === "") {
                image.source = ""
            } else if(loader_top.imageSource.includes("::PDF::")) {
                image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(loader_top.imageSource.split("::PDF::")[1]))
            } else {
                image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::PDF::%2".arg(image.currentPage).arg(loader_top.imageSource))
            }
        }

    }

    PQDocumentControls {
        id: controls
    }

}
