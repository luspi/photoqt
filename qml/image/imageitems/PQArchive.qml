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
        if(fileCount == 0)
            fileList = PQCScriptsImages.listArchiveContent(imageloaderitem.imageSource, true)
        if(imageloaderitem.imageSource.includes("::ARC::") || currentFile > fileCount-1)
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(imageloaderitem.imageSource)
        else
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::ARC::%2".arg(fileList[currentFile]).arg(imageloaderitem.imageSource))
    }

    asynchronous: true
    cache: false

    property int currentFile: 0
    property var fileList: []
    property int fileCount: fileList.length

    property bool interpThreshold: (!PQCSettings.imageviewInterpolationDisableForSmallImages || width > PQCSettings.imageviewInterpolationThreshold || height > PQCSettings.imageviewInterpolationThreshold)

    smooth: interpThreshold
    mipmap: interpThreshold

    property bool fitImage: false

    width: fitImage ? image_top.width : undefined
    height: fitImage ? image_top.height : undefined

    onVisibleChanged: {
        if(!image.visible)
            currentFile = 0
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

    onCurrentFileChanged: {
        image_top.currentFileInside = currentFile
    }

    function setSource() {
        var src = imageloaderitem.imageSource
        if(src === "") {
            image.source = ""
            return
        }

        if(src.includes("::ARC::"))
            src = src.split("::ARC::")[1]
        image.asynchronous = false

        if(fileCount == 0)
            fileList = PQCScriptsImages.listArchiveContent(imageloaderitem.imageSource, true)
        currentFile = Math.max(0, currentFile)

        if(currentFile < fileCount)
            image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding("%1::ARC::%2".arg(fileList[currentFile]).arg(src))
        else
            image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(src)
        image.asynchronous = true
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
        else if(status == Image.Ready)
            fitImage = (PQCSettings.imageviewFitInWindow && image.sourceSize.width < image_top.width && image.sourceSize.height < image_top.height)
    }

    onSourceSizeChanged: {
        loader_top.imageResolution = sourceSize
        loader_top.resetToDefaults()
        image_wrapper.startupScale = false
    }

    Connections {

        target: image_top

        function onArchiveJump(leftright) {
            image.currentFile = (image.currentFile+leftright+image.fileCount)%image.fileCount
            setSource()
        }

    }

    Connections {

        target: imageloaderitem

        function onImageSourceChanged() {
            setSource()
        }

    }

    PQArchiveControls {
        id: controls
    }

}
