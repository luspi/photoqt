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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Image {

    id: image

    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property string imageSource: ""
    property bool imageMirrorH: false
    property bool imageMirrorV: false
    property Item loaderTop
    property bool isMainImage: false

    /*******************************************/

    source: ""

    onImageSourceChanged: {
        setSource()
    }

    asynchronous: true
    cache: false

    property int currentFile: 0
    property list<string> fileList: []
    property int fileCount: fileList.length

    property bool noInterpThreshold: sourceSize.width < PQCSettings.imageviewInterpolationThreshold && sourceSize.height < PQCSettings.imageviewInterpolationThreshold

    smooth: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold
    mipmap: !PQCSettings.imageviewInterpolationDisableForSmallImages || !noInterpThreshold

    onVisibleChanged: {
        if(!image.visible)
            currentFile = 0
        else {
            PQCConstants.currentFileInsideTotal = fileCount
            PQCConstants.currentFileInsideNum = currentFile
            PQCConstants.currentFileInsideList = fileList
        }
    }

    fillMode: Image.Pad

    // we use custom mirror properties to be able to animate the mirror process with transforms
    property bool myMirrorH: false
    property bool myMirrorV: false

    onMyMirrorHChanged:
        image.imageMirrorH = myMirrorH
    onMyMirrorVChanged:
        image.imageMirrorV = myMirrorV

    function setMirrorHV(mH : bool, mV : bool) {
        image.myMirrorH = mH
        image.myMirrorV = mV
    }

    Connections {
        target: PQCScriptsShortcuts
        function onSendShortcutMirrorHorizontal() {
            if(image.visible) image.myMirrorH = !image.myMirrorH
        }
        function onSendShortcutMirrorVertical() {
            if(image.visible) image.myMirrorV = !image.myMirrorV
        }
        function onSendShortcutMirrorReset() {
            if(!image.visible) return
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
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        },
        Rotation {
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
            Behavior on angle { NumberAnimation { duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0 } }
        }
    ]

    onFileCountChanged: {
        if(isMainImage)
            PQCConstants.currentFileInsideTotal = fileCount
    }

    onCurrentFileChanged: {
        if(isMainImage) {
            PQCConstants.currentFileInsideNum = currentFile
            PQCConstants.currentFileInsideName = fileList[currentFile]
        }
    }

    onFileListChanged: {
        if(isMainImage)
            PQCConstants.currentFileInsideList = fileList
    }

    function setSource() {
        var src = image.imageSource
        if(src === "") {
            image.source = ""
            return
        }

        if(src.includes("::ARC::"))
            src = src.split("::ARC::")[1]
        image.asynchronous = false

        if(fileCount == 0)
            PQCScriptsImages.listArchiveContent(image.imageSource, true)
        else
            finishSettingSource()

    }

    function finishSettingSource() {

        var src = image.imageSource
        if(src.includes("::ARC::"))
            src = src.split("::ARC::")[1]

        currentFile = Math.max(0, currentFile)

        if(currentFile < fileCount)
            image.source = "image://full/%1::ARC::%2".arg(fileList[currentFile]).arg(PQCScriptsFilesPaths.toPercentEncoding(src))
        else
            image.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(src)
        image.asynchronous = true

    }

    Connections {

        target: PQCScriptsImages

        function onHaveArchiveContentFor(filename : string, content : list<string>) {
            if(filename === image.imageSource) {
                fileList = content
                image.finishSettingSource()
            }
        }

    }

    onStatusChanged: {
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    Connections {

        target: PQCNotify

        function onCurrentArchiveJump(leftright : int) {
            if(image.isMainImage) {
                image.currentFile = (image.currentFile+leftright+image.fileCount)%image.fileCount
                image.setSource()
            }
        }

        function onCurrentArchiveJumpTo(index : int) {
            if(image.isMainImage) {
                image.currentFile = index
                image.setSource()
            }
        }

    }

}
