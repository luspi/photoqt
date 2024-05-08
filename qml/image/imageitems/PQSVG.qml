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

import "../../elements"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsOther
import PQCScriptsClipboard
import PQCScriptsMetaData

import QtMultimedia

Item {

    id: top

    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status
    width: image.width
    height: image.height

    property bool hasAlpha: false

    Image {

        id: image

        source: (loader_top.imageSource === "" ? "" : ("image://full/" + PQCScriptsFilesPaths.toPercentEncoding(loader_top.imageSource)))

        asynchronous: true
        cache: false

        property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

        smooth: interpThreshold
        mipmap: interpThreshold

        z: parent.z

        property bool fitImage: false

        width: fitImage ? deleg.width : undefined
        height: fitImage ? deleg.height : undefined

        fillMode: fitImage ? Image.PreserveAspectFit : Image.Pad

        visible: !scaledimage.visible

        onWidthChanged:
            image_wrapper.width = width
        onHeightChanged:
            image_wrapper.height = height

        onStatusChanged: {
            image_wrapper.status = status
            if(status == Image.Ready) {
                fitImage = (PQCSettings.imageviewFitInWindow && image.sourceSize.width < deleg.width && image.sourceSize.height < deleg.height)
                hasAlpha = PQCScriptsImages.supportsTransparency(loader_top.imageSource)
            } else if(status == Image.Error)
                source = "image://svg/:/other/errorimage.svg"
        }

        // we use custom mirror properties to be able to animate the mirror process with transforms
        property bool myMirrorH: false
        property bool myMirrorV: false

        onMyMirrorHChanged:
            loader_top.imageMirrorH = myMirrorH
        onMyMirrorVChanged:
            loader_top.imageMirrorV = myMirrorV

        onSourceSizeChanged:
            loader_top.imageResolution = sourceSize

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

    }

    transform: [
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: image.myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: width / 2
            origin.y: height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile
        visible: image.status == Image.Ready && scaledimage.status == Image.Ready
        opacity: deleg.opacity
        source: PQCSettings.imageviewTransparencyMarker&&hasAlpha ? "/other/checkerboard.png" : ""

    }

    property real currentScale: 1
    Connections {
        target: loader_top
        function onImageScaleChanged() {
            resetCurrentScale.restart()
        }
    }

    Timer {
        id: resetCurrentScale
        interval: 500
        repeat: false
        onTriggered: {
            currentScale = loader_top.imageScale
        }
    }

    Image {
        id: scaledimage
        anchors.fill: parent
        source: Math.abs(1-currentScale) > 0.01 ? parent.source : ""
        visible: source !== "" && status == Image.Ready
        cache: false
        smooth: false
        mipmap: false
        z: parent.z+1
        sourceSize: Qt.size(parent.sourceSize.width*currentScale, parent.sourceSize.height*currentScale)
    }

    function setMirrorHV(mH, mV) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

}
