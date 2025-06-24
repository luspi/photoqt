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

import QtQuick
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsMetaData
import PhotoQt

Item {

    id: svgtop

    property string imageSource: ""

    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status
    width: image.width
    height: image.height

    property bool hasAlpha: false

    Image {

        id: image

        source: (svgtop.imageSource === "" ? "" : "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(svgtop.imageSource)) // qmllint disable unqualified

        asynchronous: true
        cache: false

        property bool noInterpThreshold: sourceSize.width < PQCSettings.imageviewInterpolationThreshold && sourceSize.height < PQCSettings.imageviewInterpolationThreshold

        smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold
        mipmap: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold

        z: parent.z

        fillMode: Image.Pad

        visible: !scaledimage.visible

        onStatusChanged: {
            image_wrapper.status = status // qmllint disable unqualified
            if(status == Image.Ready) {
                svgtop.hasAlpha = PQCScriptsImages.supportsTransparency(svgtop.imageSource)
            } else if(status == Image.Error)
                source = "image://svg/:/other/errorimage.svg"
        }

        // we use custom mirror properties to be able to animate the mirror process with transforms
        property bool myMirrorH: false
        property bool myMirrorV: false

        onMyMirrorHChanged:
            loader_top.imageMirrorH = myMirrorH // qmllint disable unqualified
        onMyMirrorVChanged:
            loader_top.imageMirrorV = myMirrorV // qmllint disable unqualified

        onSourceSizeChanged:
            loader_top.imageResolution = sourceSize // qmllint disable unqualified

    }

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(visible) image.myMirrorH = !image.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(visible) image.myMirrorV = !image.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!visible) return
            image.myMirrorH = false
            image.myMirrorV = false
        }
    }

    transform: [
        Rotation {
            origin.x: svgtop.width / 2
            origin.y: svgtop.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: image.myMirrorH ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        },
        Rotation {
            origin.x: svgtop.width / 2
            origin.y: svgtop.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        }
    ]

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile
        visible: image.status == Image.Ready && scaledimage.status == Image.Ready
        opacity: loader_top.opacity // qmllint disable unqualified
        source: PQCSettings.imageviewTransparencyMarker&&hasAlpha ? "/other/checkerboard.png" : "" // qmllint disable unqualified

    }

    property real currentScale: 1
    Connections {
        target: loader_top // qmllint disable unqualified
        function onImageScaleChanged() {
            resetCurrentScale.restart()
        }
    }

    Timer {
        id: resetCurrentScale
        interval: 500
        repeat: false
        onTriggered: {
            svgtop.currentScale = loader_top.imageScale // qmllint disable unqualified
        }
    }

    Image {
        id: scaledimage
        anchors.fill: parent
        source: Math.abs(1-svgtop.currentScale) > 0.01 ? svgtop.source : ""
        visible: source.toString() !== "" && status == Image.Ready
        cache: false
        smooth: false
        mipmap: false
        z: parent.z+1
        sourceSize: Qt.size(svgtop.sourceSize.width*svgtop.currentScale, svgtop.sourceSize.height*svgtop.currentScale)
    }

    Connections {
        target: image_wrapper // qmllint disable unqualified
        function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
            svgtop.setMirrorHV(mirH, mirV)
        }
    }

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

}
