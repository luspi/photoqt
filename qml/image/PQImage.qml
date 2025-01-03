pragma ComponentBehavior: Bound
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

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin // qmllint disable unqualified
    y: extraY + PQCSettings.imageviewMargin // qmllint disable unqualified
    width: toplevel.width-2*PQCSettings.imageviewMargin - lessW // qmllint disable unqualified
    height: toplevel.height-2*PQCSettings.imageviewMargin - lessH // qmllint disable unqualified

    property bool thumbnailsHoldVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && (imageIsAtDefaultScale || currentScale < defaultScale))) // qmllint disable unqualified

    property int extraX: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0 // qmllint disable unqualified
    property int extraY: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0 // qmllint disable unqualified
    property int lessW: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0 // qmllint disable unqualified
    property int lessH: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0 // qmllint disable unqualified

    property int currentlyVisibleIndex: -1
    property list<int> visibleIndexPrevCur: [-1,-1]
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

    property real currentFlickableVisibleAreaX: 0.0
    property real currentFlickableVisibleAreaY: 0.0
    property real currentFlickableVisibleAreaWidthRatio: 1.0
    property real currentFlickableVisibleAreaHeightRatio: 1.0

    property bool imageIsAtDefaultScale: Math.abs(currentScale-defaultScale) < 1e-6

    onCurrentResolutionChanged: {
        if(currentResolution.height > 0 && currentResolution.width > 0)
            PQCResolutionCache.saveResolution(PQCFileFolderModel.currentFile, currentResolution) // qmllint disable unqualified
    }

    property int currentFileInside: 0
    property int currentFilesInsideCount: 0
    property string currentFileInsideFilename: "" // whenever currentFileInside is changed this gets adjusted.

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
    property list<var> reuseChanges: []

    property int howManyLoaders: 2*PQCSettings.imageviewPreloadInBackground+2 // qmllint disable unqualified
    property int bgOffset: 0
    property list<int> bgIndices: []

    Repeater {

        id: repeaterimage

        property list<bool> allactive: [false,false,false,false,
                                        false,false,false,false,
                                        false,false,false,false]

        // we set this to the max number so that the delegates don't get reloaded when the number of images to be preloaded is changed
        model: 12

        PQImageDisplay {

            required property int modelData

            onActiveChanged:
                repeaterimage.allactive[modelData] = active

            onIAmReady: {
                image_top.newMainImageReady(modelData)
            }
            onImageLoadedAndReadyChanged: {
                if(image_top.currentlyVisibleIndex !== mainItemIndex && PQCFileFolderModel.currentIndex !== mainItemIndex) { // qmllint disable unqualified
                    if(image_top.bgOffset < image_top.bgIndices.length)
                        timer_loadbg.restart()
                }
            }
        }
    }

    Connections {

        target: PQCFileFolderModel // qmllint disable unqualified

        function onCurrentIndexChanged() {

            if(PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
                for(var i = 0; i < howManyLoaders; ++i) {
                    var curimg = repeaterimage.itemAt(i)
                    if(curimg.item)
                        curimg.item.hideImage() // qmllint disable missing-property
                }
                return
            }

            timer_loadbg.stop()

            var showItem = -1

            var newFile = PQCFileFolderModel.entriesMainView[PQCFileFolderModel.currentIndex]
            var newFolder = PQCScriptsFilesPaths.getDir(newFile)
            var newModified = PQCScriptsFilesPaths.getFileModified(newFile).toLocaleString()

            // if the current image is already loaded we only need to show it
            for(var i = 0; i < image_top.howManyLoaders; ++i) {

                var img = repeaterimage.itemAt(i)

                if(img.mainItemIndex === PQCFileFolderModel.currentIndex && img.imageSource === newFile && img.containingFolder === newFolder && img.lastModified === newModified) {
                    showItem = i
                    break;
                }

            }

            // these need to be loaded
            var cur_showing = PQCFileFolderModel.currentIndex

            image_top.bgIndices = []
            for(var b = 0; b < PQCSettings.imageviewPreloadInBackground; ++b) {
                var newp = (cur_showing-(b+1)+PQCFileFolderModel.countMainView)%PQCFileFolderModel.countMainView
                var newn = (cur_showing+(b+1))%PQCFileFolderModel.countMainView
                image_top.bgIndices.push(newp)
                image_top.bgIndices.push(newn)
            }

            // image not already loaded
            if(showItem == -1) {

                for(var j = 0; j < image_top.howManyLoaders; ++j) {

                    var spare = repeaterimage.itemAt(j)

                    // this is a spare item
                    if((image_top.bgIndices.indexOf(spare.mainItemIndex) === -1 || spare.containingFolder !== newFolder || spare.lastModified !== newModified || spare.imageSource !== newFile) && (!spare.active || !spare.item.visible)) {
                        spare.containingFolder = newFolder
                        spare.lastModified = newModified
                        spare.imageSource = newFile
                        spare.mainItemIndex = PQCFileFolderModel.currentIndex
                        spare.mainItemIndexChanged()
                        showItem = j
                        break;
                    }

                }
            }

            // show item
            for(var k = 0; k < image_top.howManyLoaders; ++k) {
                if(showItem == k) {
                    var newimg = repeaterimage.itemAt(k)
                    newimg.item.showImage()
                    break;
                }
            }

        }

    }

    function newMainImageReady(curIndex : int) {

        // hide images that should not be visible
        for(var i = 0; i < howManyLoaders; ++i) {
            var curimg = repeaterimage.itemAt(i)
            if(curIndex !== i && repeaterimage.allactive[i])
                curimg.item.hideImage() // qmllint disable missing-property
        }

        // start the timer to load images in background
        bgOffset = 0
        if(bgIndices.length > 0)
            timer_loadbg.restart()

    }

    // make sure next/prev image is loaded in background
    // we make sure this doesn't start until the main image is fully shown
    Timer {
        id: timer_loadbg
        interval: PQCSettings.imageviewAnimationDuration*100 // qmllint disable unqualified
        property list<int> prevnext: []
        onTriggered: {

            var nexttwo = [image_top.bgIndices[image_top.bgOffset], image_top.bgIndices[image_top.bgOffset+1]]
            image_top.bgOffset += 2

            // get the filepath of the previous/next files
            var prevFile = PQCFileFolderModel.entriesMainView[nexttwo[0]] // qmllint disable unqualified
            var nextFile = PQCFileFolderModel.entriesMainView[nexttwo[1]]

            // the current folder and the modified timestamps
            var curFolder = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            var prevModified = PQCScriptsFilesPaths.getFileModified(prevFile).toLocaleString()
            var nextModified = PQCScriptsFilesPaths.getFileModified(nextFile).toLocaleString()

            // first check whether images already loaded
            var foundPrev = -1
            var foundNext = -1

            // look for previous image
            if(!PQCScriptsImages.isMpvVideo(prevFile) && !PQCScriptsImages.isQtVideo(prevFile)) {
                for(var i = 0; i < image_top.howManyLoaders; ++i) {
                    var previmg = repeaterimage.itemAt(i)
                    if(previmg.mainItemIndex === nexttwo[0] && previmg.containingFolder === curFolder && previmg.lastModified === prevModified) {
                        foundPrev = i
                        break;
                    }
                }
            }

            // look for next image
            if(!PQCScriptsImages.isMpvVideo(nextFile) && !PQCScriptsImages.isQtVideo(nextFile)) {
                for(var j = 0; j < image_top.howManyLoaders; ++j) {
                    var nextimg = repeaterimage.itemAt(j)
                    if(nextimg.mainItemIndex === nexttwo[1] && nextimg.containingFolder === curFolder && nextimg.lastModified === nextModified) {
                        foundNext = j
                        break;
                    }
                }
            }

            // previous image not yet setup
            if(foundPrev == -1 && !PQCScriptsImages.isMpvVideo(prevFile) && !PQCScriptsImages.isQtVideo(prevFile)) {

                for(var k = 0; k < image_top.howManyLoaders; ++k) {

                    var curprevimg = repeaterimage.itemAt(k)

                    // k not the current main image and not the next image
                    if(curprevimg.mainItemIndex !== PQCFileFolderModel.currentIndex && (curprevimg.mainItemIndex !== foundNext || foundNext == -1)) {
                        foundPrev = k
                        curprevimg.containingFolder = curFolder
                        curprevimg.lastModified = prevModified
                        curprevimg.imageSource = PQCFileFolderModel.entriesMainView[nexttwo[0]]
                        curprevimg.mainItemIndex = nexttwo[0]
                        curprevimg.mainItemIndexChanged()
                        break;
                    }

                }

            }

            // next image not yet setup
            if(foundNext == -1 && !PQCScriptsImages.isMpvVideo(nextFile) && !PQCScriptsImages.isQtVideo(nextFile)) {

                for(var l = 0; l < image_top.howManyLoaders; ++l) {

                    var curnextimg = repeaterimage.itemAt(l)

                    // l not the current main image and not the next image
                    if(curnextimg.mainItemIndex !== PQCFileFolderModel.currentIndex && foundPrev != l) {
                        curnextimg.containingFolder = curFolder
                        curnextimg.lastModified = nextModified
                        curnextimg.imageSource = PQCFileFolderModel.entriesMainView[nexttwo[1]]
                        curnextimg.mainItemIndex = nexttwo[1]
                        curnextimg.mainItemIndexChanged()
                        break;
                    }

                }

            }


        }
    }

    // some global handlers
    function showNext() {

        if(PQCFileFolderModel.countMainView !== 0) { // qmllint disable unqualified
            if(PQCSettings.imageviewLoopThroughFolder && PQCFileFolderModel.currentIndex === PQCFileFolderModel.countMainView-1)
                PQCFileFolderModel.currentIndex = 0
            else
                PQCFileFolderModel.currentIndex = Math.min(PQCFileFolderModel.currentIndex+1, PQCFileFolderModel.countMainView-1)
        }
    }

    function showPrev() {

        if(PQCFileFolderModel.countMainView !== 0) { // qmllint disable unqualified
            if(PQCSettings.imageviewLoopThroughFolder &&PQCFileFolderModel.currentIndex === 0)
                PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
            else
                PQCFileFolderModel.currentIndex = Math.max(PQCFileFolderModel.currentIndex-1, 0)
        }
    }

    function showFirst() {
        if(PQCFileFolderModel.countMainView !== 0) // qmllint disable unqualified
            PQCFileFolderModel.currentIndex = 0
    }

    function showLast() {
        if(PQCFileFolderModel.countMainView !== 0) // qmllint disable unqualified
            PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
    }

    function showRandom() {

        if(PQCFileFolderModel.countMainView === 0 || PQCFileFolderModel.countMainView === 1) // qmllint disable unqualified
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
