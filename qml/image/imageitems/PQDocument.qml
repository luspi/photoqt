/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

Image {

    id: image

    /*******************************************/
    // these values are READONLY.

    property string imageSource: ""
    property real defaultScale
    property real currentScale
    property bool isMainImage
    property Item loaderTop


    /*******************************************/
    // these values are WRITEONLY and are picked up in PQImageDisplay

    property bool imageMirrorH: false
    property bool imageMirrorV: false

    /*******************************************/

    source: ""

    onImageSourceChanged: {
        if(imageSource === "") {
            image.source = ""
        } else if(imageSource.includes("::PDF::")) {
            image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(imageSource.split("::PDF::")[1]))
        } else {
            image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(imageSource))
        }
    }

    Component.onCompleted: {
        if(image.imageSource.includes("::PDF::"))
            source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(image.imageSource)
        else
            source = "image://full/%1::PDF::%2".arg(currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource))
    }

    asynchronous: true
    cache: false

    property bool interpThresholdMet: sourceSize.width > PQCConstants.availableWidth || sourceSize.height > PQCConstants.availableHeight

    // IMPORTANT NOTE REGARDING MIPMAP !!!
    //
    // Whenever the mipmap property changes, then the image is fully reloaded.
    // Making the mipmap property solely depend on the sourceSize makes it switch from false to true most of the time as the
    // sourceSize is reported as QSize(-1,-1) initially. This results, e.g., in the image to flicker when PhotoQt is started with one being passed on.
    // Making the mipmap property by default evaluate to true and ONLY if the image actually is below the threshold in size and the respective setting
    // is switched on, then it is set to false causing the reloading of a very small images (very fast).
    //
    // Another note about using a seperate property to store the sourceSize evaluation for both smooth and mipmap:
    // Such a property is NOT guaranteed to be evaluated before mipmap and might result in it still returning the value of QSize(-1,-1) for
    // the sourceSize even though initialLoad already caused a retrigger of mipmap.
    //
    // This property, initialLoad, ensures the 'true by default' value of mipmap and is set to false once we know the actual sourceSize.
    property bool initialLoad: true

    smooth: PQCSettings.imageviewRescalingWhichImages>0 && (PQCSettings.imageviewInterpolationFullImage===1 || PQCSettings.imageviewInterpolationFullImage===3)
    mipmap: PQCSettings.imageviewRescalingWhichImages>0 && (PQCSettings.imageviewInterpolationFullImage===2 || PQCSettings.imageviewInterpolationFullImage===3)

    onVisibleChanged: {
        if(!image.visible) {
            currentPage = 0
        } else {
            PQCConstants.currentFileInsideNum = currentPage
            PQCConstants.currentFileInsideTotal = pageCount
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

    onSourceSizeChanged: {
        image.initialLoad = false
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
            Behavior on angle {
                enabled: !PQCSettings.generalDisableAllAnimations
                NumberAnimation {
                    id: yTransform;
                    duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0
                }
            }
        },
        Rotation {
            origin.x: image.width / 2
            origin.y: image.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: image.myMirrorV ? -180 : 0
            Behavior on angle {
                enabled: !PQCSettings.generalDisableAllAnimations
                NumberAnimation {
                    id: xTransform
                    duration: PQCSettings.imageviewMirrorAnimate ? 200 : 0
                }
            }
        }
    ]

    onCurrentScaleChanged: {
        if(delayCurrentScale == 0) {
            delaySetCurrentScale.stop()
            delaySetCurrentScale.triggered()
        } else
            delaySetCurrentScale.restart()
    }

    property real delayCurrentScale: 0
    Timer {
        id: delaySetCurrentScale
        interval: 200
        triggeredOnStart: true
        onTriggered: {
            if(delaySetCurrentScale.running) {
                scaledloader.manualHidden = true
            } else {
                scaledloader.manualHidden = false
                image.delayCurrentScale = image.currentScale
            }
        }
    }

    Loader {
        id: scaledloader
        width: image.paintedWidth
        height: image.paintedHeight
        property bool manualHidden: false
        property int rescWhich: PQCSettings.imageviewRescalingWhichImages
        active: (!image.initialLoad || image.status===Image.Ready) &&
                (rescWhich===0 ||
                 ((rescWhich===1||rescWhich===3) && image.interpThresholdMet) ||
                 ((rescWhich===2||rescWhich===3) && PQCConstants.devicePixelRatio*PQCConstants.currentImageScale<1)) &&
                !xTransform.running && !yTransform.running
        asynchronous: true
        sourceComponent:
        Image {
            id: scaledimage
            width: image.paintedWidth
            height: image.paintedHeight
            source: image.source
            visible: image.status == Image.Ready && !scaledloader.manualHidden
            cache: false
            smooth: false
            mipmap: false
            z: parent.z+1
            asynchronous: false
            rotation: image.rotation
            sourceSize: Qt.size(Math.min(image.sourceSize.width, width*(image.delayCurrentScale/image.defaultScale)),
                                Math.min(image.sourceSize.height, height*(image.delayCurrentScale/image.defaultScale)))
        }
    }

    property int currentPage: 0
    property int pageCount: PQCScriptsImages.getDocumentPageCount(image.imageSource)

    onCurrentPageChanged: {
        PQCConstants.currentFileInsideNum = currentPage
        loadNewPage.restart()
    }

    onPageCountChanged: {
        PQCConstants.currentFileInsideTotal = pageCount
    }

    Timer {
        id: loadNewPage
        interval: 200
        onTriggered: {
            interval = 200
            image.asynchronous = false
            if(image.imageSource.includes("::PDF::")) {
                image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource.split("::PDF::")[1]))
            } else {
                image.source = "image://full/%1::PDF::%2".arg(image.currentPage).arg(PQCScriptsFilesPaths.toPercentEncoding(image.imageSource))
            }
            image.asynchronous = true
        }
    }

    onStatusChanged: {
        if(status == Image.Error)
            source = "image://svg/:/other/errorimage.svg"
    }

    Connections {

        target: PQCNotify

        function onCurrentDocumentJump(leftright : int) {
            loadNewPage.interval = 0
            image.currentPage = (image.currentPage+leftright+image.pageCount)%image.pageCount
        }

    }

}
