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
pragma ComponentBehavior: Bound

import QtQuick

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCResolutionCache

import org.photoqt.qml

import "../elements"

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin // qmllint disable unqualified
    y: extraY + PQCSettings.imageviewMargin // qmllint disable unqualified
    width: PQCConstants.windowWidth-2*PQCSettings.imageviewMargin - lessW // qmllint disable unqualified
    height: PQCConstants.windowHeight-2*PQCSettings.imageviewMargin - lessH // qmllint disable unqualified

    onHeightChanged:
        PQCConstants.imageQMLItemHeight = height

    property bool thumbnailsHoldVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && (imageIsAtDefaultScale || PQCConstants.currentImageScale < PQCConstants.currentImageDefaultScale))) // qmllint disable unqualified

    property int extraX: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0 // qmllint disable unqualified
    property int extraY: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0 // qmllint disable unqualified
    property int lessW: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0 // qmllint disable unqualified
    property int lessH: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0 // qmllint disable unqualified

    property string currentlyVisibleSource: ""
    property list<string> visibleSourcePrevCur: ["",""]
    onCurrentlyVisibleSourceChanged: {
        visibleSourcePrevCur[1] = visibleSourcePrevCur[0]
        visibleSourcePrevCur[0] = currentlyVisibleSource
        visibleSourcePrevCurChanged()
    }

    property bool isSomeVideoLoaded: false

    property int curZ: 0

    property real currentFlickableVisibleAreaX: 0.0
    property real currentFlickableVisibleAreaY: 0.0
    property real currentFlickableVisibleAreaWidthRatio: 1.0
    property real currentFlickableVisibleAreaHeightRatio: 1.0

    property bool imageIsAtDefaultScale: Math.abs(PQCConstants.currentImageScale-PQCConstants.currentImageDefaultScale) < 1e-6

    property string randomAnimation: "opacity"

    property point extraControlsLocation: Qt.point(-1,-1)

    signal playPauseAnimationVideo()
    signal moveView(var direction)
    signal flickView(var direction)
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
    property list<string> bgFiles: []

    property bool componentComboOpen: false
    signal closeAllMenus()

    Repeater {

        id: repeaterimage

        property list<bool> allactive: [false,false,false,false,
                                        false,false,false,false,
                                        false,false,false,false]

        // we set this to the max number so that the delegates don't get reloaded when the number of images to be preloaded is changed
        model: 12

        PQImageDisplay {

            required property int modelData

            onActiveChanged: {
                repeaterimage.allactive[modelData] = active
            }

            onIAmReady: {
                image_top.newMainImageReady(modelData)
            }
            onImageLoadedAndReadyChanged: {
                if(image_top.currentlyVisibleSource !== imageSource && PQCFileFolderModel.currentFile !== imageSource) { // qmllint disable unqualified
                    if(image_top.bgOffset < image_top.bgFiles.length)
                        timer_loadbg.restart()
                }
            }
        }
    }

    Component.onCompleted: {

        if(PQCConstants.startupFileLoad != "") {

            var img = repeaterimage.itemAt(0)

            if(img === null) {
                loadFirstImage.start()
                return
            }

            img.containingFolder = PQCScriptsFilesPaths.getDir(PQCConstants.startupFileLoad)
            img.lastModified = PQCScriptsFilesPaths.getFileModified(PQCConstants.startupFileLoad).toLocaleString()
            img.imageSource = PQCConstants.startupFileLoad
            img.thisIsStartupFile = true

        }

    }

    Timer {
        id: loadFirstImage
        interval: 10
        onTriggered: {
            var img = repeaterimage.itemAt(0)
            if(img === null) {
                loadFirstImage.restart()
                return
            }

            img.containingFolder = PQCScriptsFilesPaths.getDir(PQCConstants.startupFileLoad)
            img.lastModified = PQCScriptsFilesPaths.getFileModified(PQCConstants.startupFileLoad).toLocaleString()
            img.imageSource = PQCConstants.startupFileLoad
            img.thisIsStartupFile = true

        }
    }

    Connections {

        target: PQCScriptsShortcuts

        function onSendShortcutShowNextImage() {
            image_top.showNext()
        }

        function onSendShortcutShowPrevImage() {
            image_top.showPrev()
        }

        function onSendShortcutShowFirstImage() {
            image_top.showFirst()
        }

        function onSendShortcutShowLastImage() {
            image_top.showLast()
        }

        function onSendShortcutShowRandomImage() {
            image_top.showRandom()
        }

    }

    Connections {

        target: PQCFileFolderModel // qmllint disable unqualified

        function onCurrentIndexChanged() {

            if(PQCConstants.ignoreFileFolderChangesTemporary) {
                console.debug("Ignoring new currentIndex:", PQCFileFolderModel.currentIndex)
                return
            }

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

                if(img.imageSource === newFile && img.containingFolder === newFolder && img.lastModified === newModified) {
                    showItem = i
                    break;
                }

            }

            // these need to be loaded
            var cur_showing = PQCFileFolderModel.currentIndex

            image_top.bgFiles = []
            for(var b = 0; b < PQCSettings.imageviewPreloadInBackground; ++b) {
                var newp = (cur_showing-(b+1)+PQCFileFolderModel.countMainView)%PQCFileFolderModel.countMainView
                var newn = (cur_showing+(b+1))%PQCFileFolderModel.countMainView
                image_top.bgFiles.push(PQCFileFolderModel.entriesMainView[newp])
                image_top.bgFiles.push(PQCFileFolderModel.entriesMainView[newn])
            }

            // image not already loaded
            if(showItem == -1) {

                for(var j = 0; j < image_top.howManyLoaders; ++j) {

                    var spare = repeaterimage.itemAt(j)

                    // this is a spare item
                    if((image_top.bgFiles.indexOf(spare.imageSource) === -1 || spare.containingFolder !== newFolder || spare.lastModified !== newModified || spare.imageSource !== newFile) && (!spare.active || !spare.item.visible)) {
                        spare.containingFolder = newFolder
                        spare.lastModified = newModified
                        spare.imageSource = newFile
                        spare.thisIsStartupFile = false
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
                    newimg.thisIsStartupFile = false
                    break;
                }
            }

        }

    }

    function newMainImageReady(curIndex : int) {

        // hide images that should not be visible
        for(var i = 0; i < howManyLoaders; ++i) {
            var curimg = repeaterimage.itemAt(i)
            if(curIndex !== i && repeaterimage.allactive[i]) {
                curimg.item.hideImage()
                curimg.thisIsStartupFile = false
            }
        }

        // start the timer to load images in background
        bgOffset = 0
        if(bgFiles.length > 0)
            timer_loadbg.restart()

    }

    // make sure next/prev image is loaded in background
    // we make sure this doesn't start until the main image is fully shown
    Timer {
        id: timer_loadbg
        interval: PQCSettings.imageviewAnimationDuration*100 // qmllint disable unqualified
        onTriggered: {

            var nexttwo = [image_top.bgFiles[image_top.bgOffset], image_top.bgFiles[image_top.bgOffset+1]]
            image_top.bgOffset += 2

            // get the filepath of the previous/next files
            var prevFile = nexttwo[0]
            var nextFile = nexttwo[1]

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
                    if(previmg.imageSource === prevFile && previmg.containingFolder === curFolder && previmg.lastModified === prevModified) {
                        foundPrev = i
                        break;
                    }
                }
            }

            // look for next image
            if(!PQCScriptsImages.isMpvVideo(nextFile) && !PQCScriptsImages.isQtVideo(nextFile)) {
                for(var j = 0; j < image_top.howManyLoaders; ++j) {
                    var nextimg = repeaterimage.itemAt(j)
                    if(nextimg.imageSource === nextFile && nextimg.containingFolder === curFolder && nextimg.lastModified === nextModified) {
                        foundNext = j
                        break;
                    }
                }
            }

            // previous image not yet setup
            if(foundPrev == -1 && !PQCScriptsImages.isMpvVideo(prevFile) && !PQCScriptsImages.isQtVideo(prevFile)) {

                var thenextimg = repeaterimage.itemAt(foundNext)

                for(var k = 0; k < image_top.howManyLoaders; ++k) {

                    var curprevimg = repeaterimage.itemAt(k)

                    // k not the current main image and not the next image
                    if(curprevimg.imageSource !== PQCFileFolderModel.currentFile && (foundNext === -1 || curprevimg.imageSource !== thenextimg.imageSource)) {
                        foundPrev = k
                        curprevimg.containingFolder = curFolder
                        curprevimg.lastModified = prevModified
                        curprevimg.imageSource = prevFile
                        break;
                    }

                }

            }

            // next image not yet setup
            if(foundNext == -1 && !PQCScriptsImages.isMpvVideo(nextFile) && !PQCScriptsImages.isQtVideo(nextFile)) {

                for(var l = 0; l < image_top.howManyLoaders; ++l) {

                    var curnextimg = repeaterimage.itemAt(l)

                    // l not the current main image and not the next image
                    if(curnextimg.imageSource !== PQCFileFolderModel.currentFile && foundPrev != l) {
                        curnextimg.containingFolder = curFolder
                        curnextimg.lastModified = nextModified
                        curnextimg.imageSource = nextFile
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
