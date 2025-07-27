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
import PhotoQt.Shared

Item {

    id: svgtop

    /*******************************************/
    // these values are READONLY, they are set in PQImageDisplay as bindings

    property string imageSource: ""
    property real loaderTopOpacity
    property real loaderTopImageScale

    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property bool imageMirrorH: false
    property bool imageMirrorV: false

    /*******************************************/

    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status
    width: image.width
    height: image.height

    property bool hasAlpha: false

    Image {

        id: image

        source: (svgtop.imageSource === "" ? "" : "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(svgtop.imageSource))

        asynchronous: true
        cache: false

        property bool noInterpThreshold: sourceSize.width < PQCSettings.imageviewInterpolationThreshold && sourceSize.height < PQCSettings.imageviewInterpolationThreshold

        smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold
        mipmap: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold

        z: parent.z

        fillMode: Image.Pad

        visible: !scaledimage.visible

        onStatusChanged: {
            if(status == Image.Ready) {
                svgtop.hasAlpha = PQCScriptsImages.supportsTransparency(svgtop.imageSource)
            } else if(status == Image.Error)
                source = "image://svg/:/other/errorimage.svg"
        }

        // we use custom mirror properties to be able to animate the mirror process with transforms
        property bool myMirrorH: false
        property bool myMirrorV: false

        onMyMirrorHChanged:
            svgtop.imageMirrorH = myMirrorH
        onMyMirrorVChanged:
            svgtop.imageMirrorV = myMirrorV

    }

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(svgtop.visible) image.myMirrorH = !image.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(svgtop.visible) image.myMirrorV = !image.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!svgtop.visible) return
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
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: svgtop.width / 2
            origin.y: svgtop.height / 2
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
        opacity: svgtop.loaderTopOpacity
        source: PQCSettings.imageviewTransparencyMarker&&svgtop.hasAlpha ? "/other/checkerboard.png" : ""

    }

    property real currentScale: 1

    function restartResetCurrentScale() {
        resetCurrentScale.restart()
    }

    Timer {
        id: resetCurrentScale
        interval: 500
        repeat: false
        onTriggered: {
            svgtop.currentScale = svgtop.loaderTopImageScale
        }
    }

    Image {
        id: scaledimage
        anchors.fill: parent
        source: Math.abs(1-svgtop.currentScale) > 0.01 ? svgtop.source : ""
        visible: source !== Qt.url("") && status == Image.Ready
        cache: false
        smooth: false
        mipmap: false
        z: parent.z+1
        sourceSize: Qt.size(svgtop.sourceSize.width*svgtop.currentScale, svgtop.sourceSize.height*svgtop.currentScale)
    }

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

}
