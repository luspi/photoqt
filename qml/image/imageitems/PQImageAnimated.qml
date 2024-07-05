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
import "../components"

import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCScriptsClipboard
import PQCScriptsOther
import PQCNotify

AnimatedImage {

    id: image

    source: (loader_top.imageSource==="" ? "" : ("file:/" + PQCScriptsFilesPaths.toPercentEncoding(loader_top.imageSource)))

    asynchronous: true

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: Math.abs(image_wrapper.scale-1) < 0.1 ? false : interpThreshold
    mipmap: interpThreshold

    property bool fitImage: false
    property bool imageLarger: (image.sourceSize.width > image_top.width || image.sourceSize.height > image_top.height)

    width: (fitImage||imageLarger) ? image_top.width : undefined
    height: (fitImage||imageLarger) ? image_top.height : undefined

    fillMode: Image.PreserveAspectFit

    onWidthChanged:
        image_wrapper.width = width
    onHeightChanged:
        image_wrapper.height = height

    onStatusChanged: {
        image_wrapper.status = status
        if(status == Image.Ready) {
            fitImage = (PQCSettings.imageviewFitInWindow && image.sourceSize.width < image_top.width && image.sourceSize.height < image_top.height)
            hasAlpha = PQCScriptsImages.supportsTransparency(loader_top.imageSource)
            if(loader_top.defaultScale < 0.95)
                loadScaledDown.restart()
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

    property bool hasAlpha: false

    onSourceSizeChanged:
        loader_top.imageResolution = sourceSize

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
            angle: myMirrorV ? 180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    Image {
        anchors.fill: parent
        z: parent.z-1
        fillMode: Image.Tile

        source: PQCSettings.imageviewTransparencyMarker&&image.hasAlpha ? "/other/checkerboard.png" : ""

    }
    function setMirrorHV(mH, mV) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    Connections {

        target: loader_top
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

        target: image_top

        function onCurrentlyVisibleIndexChanged() {
            image.playing = loader_top.isMainImage
        }

        function onAnimImageJump(leftright) {
            image.currentFrame = (image.currentFrame+leftright+image.frameCount)%image.frameCount
        }

    }

    PQImageAnimatedControls { id: controls }

}
