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

    PQImageDisplay {
        id: image1
        onIAmReady:
            newMainImageReady(1)
    }
    PQImageDisplay {
        id: image2
        onIAmReady:
            newMainImageReady(2)
    }
    PQImageDisplay {
        id: image3
        onIAmReady:
            newMainImageReady(3)
    }
    PQImageDisplay {
        id: image4
        onIAmReady:
            newMainImageReady(4)
    }

    Connections {

        target: PQCFileFolderModel

        function onCurrentIndexChanged() {

            timer_loadbg.stop()

            var showItem = -1

            var newFolder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            var newModified = PQCScriptsFilesPaths.getFileModified(PQCFileFolderModel.currentFile).toLocaleString()

            // if the current image is already loaded we only need to show it
            if(image1.mainItemIndex === PQCFileFolderModel.currentIndex && image1.containingFolder === newFolder && image1.lastModified === newModified) {
                // image1.
                showItem = 1
            } else if(image2.mainItemIndex === PQCFileFolderModel.currentIndex && image2.containingFolder === newFolder && image2.lastModified === newModified) {
                showItem = 2
            } else if(image3.mainItemIndex === PQCFileFolderModel.currentIndex && image3.containingFolder === newFolder && image3.lastModified === newModified) {
                showItem = 3
            } else if(image4.mainItemIndex === PQCFileFolderModel.currentIndex && image4.containingFolder === newFolder && image4.lastModified === newModified) {
                showItem = 4
            }

            // these need to be loaded
            _showing = PQCFileFolderModel.currentIndex
            _loadBg = [(_showing-1+PQCFileFolderModel.countMainView)%PQCFileFolderModel.countMainView, (_showing+1)%PQCFileFolderModel.countMainView]

            // image not already loaded
            if(showItem == -1) {
                // image1 is a spare item
                if((_loadBg.indexOf(image1.mainItemIndex) == -1 || image1.containingFolder !== newFolder || image1.lastModified !== newModified) && (!image1.active || !image1.item.visible)) {
                    image1.mainItemIndex = PQCFileFolderModel.currentIndex
                    image1.containingFolder = newFolder
                    image1.lastModified = newModified
                    showItem = 1
                // image2 is a spare item
                } else if((_loadBg.indexOf(image2.mainItemIndex) == -1 || image2.containingFolder !== newFolder || image2.lastModified !== newModified) && (!image2.active || !image2.item.visible)) {
                    image2.mainItemIndex = PQCFileFolderModel.currentIndex
                    image2.containingFolder = newFolder
                    image2.lastModified = newModified
                    showItem = 2
                // image3 is a spare item
                } else if((_loadBg.indexOf(image3.mainItemIndex) == -1 || image3.containingFolder !== newFolder || image3.lastModified !== newModified) && (!image3.active || !image3.item.visible)) {
                    image3.mainItemIndex = PQCFileFolderModel.currentIndex
                    image3.containingFolder = newFolder
                    image3.lastModified = newModified
                    showItem = 3
                // image4 is a spare item
                } else if((_loadBg.indexOf(image4.mainItemIndex) == -1 || image4.containingFolder !== newFolder || image4.lastModified !== newModified) && (!image4.active || !image4.item.visible)) {
                    image4.mainItemIndex = PQCFileFolderModel.currentIndex
                    image4.containingFolder = newFolder
                    image4.lastModified = newModified
                    showItem = 4
                }
            }

            // store the prev/next entries
            timer_loadbg.prevnext = _loadBg

            // start busy timer
            timer_busyloading.restart()

            // show item
            if(showItem == 1) {
                image1.item.showImage()
            } else if(showItem == 2) {
                image2.item.showImage()
            } else if(showItem == 3) {
                image3.item.showImage()
            } else if(showItem == 4) {
                image4.item.showImage()
            }

        }

    }

    function newMainImageReady(curIndex) {

        // stop busy timer and hide indicator
        timer_busyloading.stop()
        busyloading.hide()

        // hide images that should not be visible
        if(curIndex !== 1 && image1.active) image1.item.hideImage()
        if(curIndex !== 2 && image2.active) image2.item.hideImage()
        if(curIndex !== 3 && image3.active) image3.item.hideImage()
        if(curIndex !== 4 && image4.active) image4.item.hideImage()

        // staart the timer to load images in background
        timer_loadbg.restart()

    }

    // make sure next/prev image is loaded in background
    // we make sure this doesn't start until the main image is fully shown
    Timer {
        id: timer_loadbg
        interval: PQCSettings.imageviewAnimationDuration*100
        property var prevnext: []
        onTriggered: {

            // get the filepath of the previous/next files
            var prevFile = PQCFileFolderModel.entriesMainView[prevnext[0]]
            var nextFile = PQCFileFolderModel.entriesMainView[prevnext[1]]

            // the current folder and the modified timestamps
            var curFolder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            var prevModified = PQCScriptsFilesPaths.getFileModified(prevFile).toLocaleString()
            var nextModified = PQCScriptsFilesPaths.getFileModified(nextFile).toLocaleString()

            // first check whether images already loaded
            var foundPrev = -1
            var foundNext = -1

            // look for previous image
            if(image1.mainItemIndex === prevnext[0] && image1.containingFolder === curFolder && image1.lastModified === prevModified) {
                foundPrev = 1
            } else if(image2.mainItemIndex === prevnext[0] && image2.containingFolder === curFolder && image2.lastModified === prevModified) {
                foundPrev = 2
            } else if(image3.mainItemIndex === prevnext[0] && image3.containingFolder === curFolder && image3.lastModified === prevModified) {
                foundPrev = 3
            } else if(image4.mainItemIndex === prevnext[0] && image4.containingFolder === curFolder && image4.lastModified === prevModified) {
                foundPrev = 4
            }

            // look for next image
            if(image1.mainItemIndex === prevnext[1] && image1.containingFolder === curFolder && image1.lastModified === nextModified) {
                foundNext = 1
            } else if(image2.mainItemIndex === prevnext[1] && image2.containingFolder === curFolder && image2.lastModified === nextModified) {
                foundNext = 2
            } else if(image3.mainItemIndex === prevnext[1] && image3.containingFolder === curFolder && image3.lastModified === nextModified) {
                foundNext = 3
            } else if(image4.mainItemIndex === prevnext[1] && image4.containingFolder === curFolder && image4.lastModified === nextModified) {
                foundNext = 4
            }

            // previous image not yet setup
            if(foundPrev == -1) {

                // 1 not the current main image and not the next image
                if(image1.mainItemIndex !== PQCFileFolderModel.currentIndex && (image1.mainItemIndex != foundNext || foundNext == -1)) {
                    foundPrev = 1
                    image1.mainItemIndex = prevnext[0]
                    image1.containingFolder = curFolder
                    image1.lastModified = prevModified
                // 2 not the current main image and not the next image
                } else if(image2.mainItemIndex !== PQCFileFolderModel.currentIndex && (image2.mainItemIndex != foundNext || foundNext == -1)) {
                    foundPrev = 2
                    image2.mainItemIndex = prevnext[0]
                    image2.containingFolder = curFolder
                    image2.lastModified = prevModified
                // 3 not the current main image and not the next image
                } else if(image3.mainItemIndex !== PQCFileFolderModel.currentIndex && (image3.mainItemIndex != foundNext || foundNext == -1)) {
                    foundPrev = 3
                    image3.mainItemIndex = prevnext[0]
                    image3.containingFolder = curFolder
                    image3.lastModified = prevModified
                // 4 not the current main image and not the next image
                } else if(image4.mainItemIndex !== PQCFileFolderModel.currentIndex && (image4.mainItemIndex != foundNext || foundNext == -1)) {
                    foundPrev = 4
                    image4.mainItemIndex = prevnext[0]
                    image4.containingFolder = curFolder
                    image4.lastModified = prevModified
                }

            }

            // next image not yet setup
            if(foundNext == -1) {

                // 1 not the current main image and not the next image
                if(image1.mainItemIndex !== PQCFileFolderModel.currentIndex && foundPrev != 1) {
                    image1.mainItemIndex = prevnext[1]
                    image1.containingFolder = curFolder
                    image1.lastModified = nextModified
                // 2 not the current main image and not the next image
                } else if(image2.mainItemIndex !== PQCFileFolderModel.currentIndex && foundPrev != 2) {
                    image2.mainItemIndex = prevnext[1]
                    image2.containingFolder = curFolder
                    image2.lastModified = nextModified
                // 3 not the current main image and not the next image
                } else if(image3.mainItemIndex !== PQCFileFolderModel.currentIndex && foundPrev != 3) {
                    image3.mainItemIndex = prevnext[1]
                    image3.containingFolder = curFolder
                    image3.lastModified = nextModified
                // 4 not the current main image and not the next image
                } else if(image4.mainItemIndex !== PQCFileFolderModel.currentIndex && foundPrev != 4) {
                    image4.mainItemIndex = prevnext[1]
                    image4.containingFolder = curFolder
                    image4.lastModified = nextModified
                }

            }


        }
    }


    // BUSY indicator
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
