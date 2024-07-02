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

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCResolutionCache

import "../elements"
import "./components"
import "./imageitems"

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin
    y: extraY + PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin - lessW
    height: toplevel.height-2*PQCSettings.imageviewMargin - lessH

    property bool thumbnailsHoldVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && (imageIsAtDefaultScale || currentScale < defaultScale)))

    property int extraX: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0
    property int extraY: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0
    property int lessW: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0
    property int lessH: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0

    property int currentlyVisibleIndex: -1
    property var visibleIndexPrevCur: [-1,-1]
    onCurrentlyVisibleIndexChanged: {
        visibleIndexPrevCur[1] = visibleIndexPrevCur[0]
        visibleIndexPrevCur[0] = currentlyVisibleIndex
        visibleIndexPrevCurChanged()
    }
    property bool isSomeVideoLoaded: false

    // this is set to true once an image is shown
    // this is used, e.g., to detect when to start loading thumbnails
    property bool initialLoadingFinished: false

    property int curZ: 0
    property real defaultScale: 1
    property real currentScale: 1
    property real currentRotation: 0
    property size currentResolution: Qt.size(0,0)

    property bool imageIsAtDefaultScale: Math.abs(currentScale-defaultScale) < 1e-6

    onCurrentResolutionChanged: {
        if(currentResolution.height > 0 && currentResolution.width > 0)
            PQCResolutionCache.saveResolution(PQCFileFolderModel.currentFile, currentResolution)
    }

    property int currentFileInside: 0

    property string randomAnimation: "opacity"

    property point extraControlsLocation: Qt.point(-1,-1)

    property bool currentlyShowingVideo: false
    property bool currentlyShowingVideoPlaying: false
    property bool currentlyShowingVideoHasAudio: false

    signal zoomIn(var wheelDelta)
    signal zoomOut(var wheelDelta)
    signal zoomReset()
    signal zoomActual()
    signal rotateClock()
    signal rotateAntiClock()
    signal rotateReset()
    signal mirrorH()
    signal mirrorV()
    signal mirrorReset()
    signal playPauseAnimationVideo()
    signal moveView(var direction)
    signal detectBarCodes()
    signal barcodeClick()
    signal videoJump(var seconds)
    signal animImageJump(var leftright)
    signal documentJump(var leftright)
    signal archiveJump(var leftright)

    signal animatePhotoSpheres(var direction)

    signal imageFinishedLoading(var index)
    signal reloadImage()
    signal enterPhotoSphere()
    signal exitPhotoSphere()

    property var rememberChanges: ({})
    property var reuseChanges: []

    property int _showing: -1
    property var _loadBg: [-1,-1]
    property int _spareItem: -1

    Loader {
        id: image1
        property int componentIndex: 1
        property int mainItemIndex: -1
        property bool imageLoadedAndReady: false
        onMainItemIndexChanged: {
            imageLoadedAndReady = false
            active = false
            active = (mainItemIndex!=-1)
            if(active) {
                item.componentIndex = componentIndex
                item.mainItemIndex = image1.mainItemIndex
                item.finishSetup()
            }
        }
        active: false
        sourceComponent:
            PQImageDisplayNew {}
    }

    Loader {
        id: image2
        property int componentIndex: 2
        property int mainItemIndex: -1
        property bool imageLoadedAndReady: false
        onMainItemIndexChanged: {
            imageLoadedAndReady = false
            active = false
            active = (mainItemIndex!=-1)
            if(active) {
                item.componentIndex = componentIndex
                item.mainItemIndex = image2.mainItemIndex
                item.finishSetup()
            }
        }
        active: false
        sourceComponent:
            PQImageDisplayNew {}
    }

    Loader {
        id: image3
        property int componentIndex: 3
        property int mainItemIndex: -1
        property bool imageLoadedAndReady: false
        onMainItemIndexChanged: {
            imageLoadedAndReady = false
            active = false
            active = (mainItemIndex!=-1)
            if(active) {
                item.componentIndex = componentIndex
                item.mainItemIndex = image3.mainItemIndex
                item.finishSetup()
            }
        }
        active: false
        sourceComponent:
            PQImageDisplayNew {}
    }

    Loader {
        id: image4
        property int componentIndex: 4
        property int mainItemIndex: -1
        property bool imageLoadedAndReady: false
        onMainItemIndexChanged: {
            imageLoadedAndReady = false
            active = false
            active = (mainItemIndex!=-1)
            if(active) {
                item.componentIndex = componentIndex
                item.mainItemIndex = image4.mainItemIndex
                item.finishSetup()
            }
        }
        active: false
        sourceComponent:
            PQImageDisplayNew {}
    }

    Connections {

        target: PQCFileFolderModel

        function onCurrentIndexChanged() {

            var showItem = -1
            var showItemIsAlreadyReady = false

            // TODO: also add check to whether folder changed
            //       otherwise loading the same index in a different folder will fail

            // if the current image is already loaded we only need to show it
            if(image1.mainItemIndex === PQCFileFolderModel.currentIndex) {
                showItem = 1
                if(image1.imageLoadedAndReady) showItemIsAlreadyReady = true
            } else if(image2.mainItemIndex === PQCFileFolderModel.currentIndex) {
                showItem = 2
                if(image2.imageLoadedAndReady) showItemIsAlreadyReady = true
            } else if(image3.mainItemIndex === PQCFileFolderModel.currentIndex) {
                showItem = 3
                if(image3.imageLoadedAndReady) showItemIsAlreadyReady = true
            } else if(image4.mainItemIndex === PQCFileFolderModel.currentIndex) {
                showItem = 4
                if(image4.imageLoadedAndReady) showItemIsAlreadyReady = true
            }

            // these need to be loaded
            _showing = PQCFileFolderModel.currentIndex
            _loadBg = [(_showing-1+PQCFileFolderModel.countMainView)%PQCFileFolderModel.countMainView, (_showing+1)%PQCFileFolderModel.countMainView]

            // image not already loaded
            if(showItem == -1) {
                // image1 is a spare item
                if(_loadBg.indexOf(image1.mainItemIndex) == -1 && (!image1.active || !image1.item.visible)) {
                    image1.mainItemIndex = PQCFileFolderModel.currentIndex
                    showItem = 1
                // image2 is a spare item
                } else if(_loadBg.indexOf(image2.mainItemIndex) == -1 && (!image2.active || !image2.item.visible)) {
                    image2.mainItemIndex = PQCFileFolderModel.currentIndex
                    showItem = 2
                // image3 is a spare item
                } else if(_loadBg.indexOf(image3.mainItemIndex) == -1 && (!image3.active || !image3.item.visible)) {
                    image3.mainItemIndex = PQCFileFolderModel.currentIndex
                    showItem = 3
                // image4 is a spare item
                } else if(_loadBg.indexOf(image4.mainItemIndex) == -1 && (!image4.active || !image4.item.visible)) {
                    image4.mainItemIndex = PQCFileFolderModel.currentIndex
                    showItem = 4
                }
            }

            timer_busyloading.restart()

            if(showItem == 1) {
                image1.item.showImage()
                if(showItemIsAlreadyReady)
                    newMainImageReady(1)
            } else if(showItem == 2) {
                image2.item.showImage()
                if(showItemIsAlreadyReady)
                    newMainImageReady(2)
            } else if(showItem == 3) {
                image3.item.showImage()
                if(showItemIsAlreadyReady)
                    newMainImageReady(3)
            } else if(showItem == 4) {
                image4.item.showImage()
                if(showItemIsAlreadyReady)
                    newMainImageReady(4)
            }

        }

    }

    function newMainImageReady(curIndex) {
        timer_busyloading.stop()
        busyloading.hide()
        if(curIndex !== 1 && image1.active) image1.item.hideImage()
        if(curIndex !== 2 && image2.active) image2.item.hideImage()
        if(curIndex !== 3 && image3.active) image3.item.hideImage()
        if(curIndex !== 4 && image4.active) image4.item.hideImage()
    }

    Timer {
        id: timer_busyloading
        interval: 500
        onTriggered: {
            if(!PQCNotify.slideshowRunning)
                busyloading.showBusy()
        }
    }

    PQWorking {
        id: busyloading
        anchors.margins: -PQCSettings.imageviewMargin
        z: image_top.curZ+1
    }

    // some global handlers
    function showNext() {
        if(PQCFileFolderModel.countMainView !== 0) {
            if(PQCSettings.imageviewLoopThroughFolder && PQCFileFolderModel.currentIndex === PQCFileFolderModel.countMainView-1)
                PQCFileFolderModel.currentIndex = 0
            else
                PQCFileFolderModel.currentIndex = Math.min(PQCFileFolderModel.currentIndex+1, PQCFileFolderModel.countMainView-1)
        }
    }

    function showPrev() {
        if(PQCFileFolderModel.countMainView !== 0) {
            if(PQCSettings.imageviewLoopThroughFolder &&PQCFileFolderModel.currentIndex === 0)
                PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
            else
                PQCFileFolderModel.currentIndex = Math.max(PQCFileFolderModel.currentIndex-1, 0)
        }
    }

    function showFirst() {
        if(PQCFileFolderModel.countMainView !== 0)
            PQCFileFolderModel.currentIndex = 0
    }

    function showLast() {
        if(PQCFileFolderModel.countMainView !== 0)
            PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
    }

    function showRandom() {

        if(PQCFileFolderModel.countMainView === 0 || PQCFileFolderModel.countMainView === 1)
            return

        // special case: load other image
        if(PQCFileFolderModel.countMainView === 2)
            PQCFileFolderModel.currentIndex = (PQCFileFolderModel.currentIndex+1)%2

        // find new image that's not the current one (if possible)
        var ran = PQCFileFolderModel.currentIndex
        var iter = 0
        while(ran === PQCFileFolderModel.currentIndex) {
            ran = Math.floor(Math.random() * PQCFileFolderModel.countMainView);
            iter += 1
            if(iter > 100)
                break
        }
        PQCFileFolderModel.currentIndex = ran
    }

}
