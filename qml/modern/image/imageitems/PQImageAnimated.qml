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

import "../components"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCScriptsClipboard
import PQCScriptsOther

AnimatedImage {

    id: image

    property string imageSource: ""

    source: (image.imageSource==="" ? "" : ("file:"+PQCScriptsFilesPaths.toPercentEncoding(image.imageSource))) // qmllint disable unqualified

    asynchronous: true

    property bool noInterpThreshold: sourceSize.width < PQCSettings.imageviewInterpolationThreshold && sourceSize.height < PQCSettings.imageviewInterpolationThreshold

    smooth: Math.abs(image_wrapper.scale-1) < 0.1 ? false : (!PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold)
    mipmap: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold

    onStatusChanged: {
        image_wrapper.status = status // qmllint disable unqualified
        if(status == Image.Ready) {
            hasAlpha = PQCScriptsImages.supportsTransparency(image.imageSource)
        } else if(status == Image.Error)
            source = "qrc:/other/errorimage.svg"
    }

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        loader_top.imageMirrorH = myMirrorH // qmllint disable unqualified
    onMyMirrorVChanged:
        loader_top.imageMirrorV = myMirrorV // qmllint disable unqualified

    property bool hasAlpha: false

    onSourceSizeChanged:
        loader_top.imageResolution = sourceSize // qmllint disable unqualified

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
            angle: image.myMirrorV ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } } // qmllint disable unqualified
        }
    ]

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile

        source: PQCSettings.imageviewTransparencyMarker&&image.hasAlpha ? "/other/checkerboard.png" : "" // qmllint disable unqualified

    }

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

        target: loader_top // qmllint disable unqualified
        function onVideoTogglePlay() {
            if(!image.playing) {
                // without explicitely storing/loading the frame it will restart playing at the start
                var fr = image.currentFrame
                image.playing = true
                image.currentFrame = fr
            } else
                image.playing = false
        }

    }

    Connections {

        target: image_top // qmllint disable unqualified

        function onCurrentlyVisibleIndexChanged() {
            image.playing = loader_top.isMainImage // qmllint disable unqualified
        }

        function onAnimImageJump(leftright : int) {
            image.currentFrame = (image.currentFrame+leftright+image.frameCount)%image.frameCount
        }

    }

    PQImageAnimatedControls { id: controls }

}
