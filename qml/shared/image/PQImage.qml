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
import PQCResolutionCache
import PhotoQt.Shared

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin
    y: extraY + PQCSettings.imageviewMargin
    width: toplevelItem.width-2*PQCSettings.imageviewMargin// - lessW
    height: toplevelItem.height-2*PQCSettings.imageviewMargin// - lessH

    onWidthChanged:
        PQCConstants.imageDisplaySize.width = width
    onHeightChanged:
        PQCConstants.imageDisplaySize.height = height

    property Item toplevelItem

    property bool thumbnailsHoldVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && (imageIsAtDefaultScale || PQCConstants.currentImageScale < PQCConstants.currentImageDefaultScale)))

    property int extraX: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails") ? PQCConstants.thumbnailsBarWidth : 0
    property int extraY: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails") ? PQCConstants.thumbnailsBarHeight : 0
    property int lessW: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails") ? PQCConstants.thumbnailsBarWidth : 0
    property int lessH: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails") ? PQCConstants.thumbnailsBarHeight : 0

    property list<string> visibleSourcePrevCur: ["",""]
    Connections{

        target: PQCConstants

        function onCurrentImageSourceChanged() {
            visibleSourcePrevCur[1] = visibleSourcePrevCur[0]
            visibleSourcePrevCur[0] = PQCConstants.currentImageSource
            visibleSourcePrevCurChanged()
            PQCNotify.currentImageLoadedAndDisplayed(PQCConstants.currentImageSource)
        }

    }

    property bool isSomeVideoLoaded: false

    property bool imageIsAtDefaultScale: Math.abs(PQCConstants.currentImageScale-PQCConstants.currentImageDefaultScale) < 1e-6

    property string randomAnimation: "opacity"

    property point extraControlsLocation: Qt.point(-1,-1)

    signal animatePhotoSpheres(var direction)

    property var rememberChanges: ({})
    property list<var> reuseChanges: []

    property int howManyLoaders: 2*PQCSettings.imageviewPreloadInBackground+2
    property int bgOffset: 0
    property list<string> bgFiles: []

    Repeater {

        id: repeaterimage

        property list<bool> allactive: [false,false,false,false,
                                        false,false,false,false,
                                        false,false,false,false]

        // we set this to the max number so that the delegates don't get reloaded when the number of images to be preloaded is changed
        model: 12

        PQImageDisplay {

            required property int modelData

            toplevelItem: image_top.toplevelItem

            onActiveChanged: {
                repeaterimage.allactive[modelData] = active
            }

            onIAmReady: {
                image_top.newMainImageReady(modelData)
            }
            onImageLoadedAndReadyChanged: {
                if(PQCConstants.currentImageSource !== imageSource && PQCFileFolderModel.currentFile !== imageSource) {
                    if(image_top.bgOffset < image_top.bgFiles.length)
                        timer_loadbg.restart()
                }
            }
        }
    }

    Loader {
        id: minimap_loader
        active: PQCSettings.imageviewShowMinimap && !PQCConstants.showingPhotoSphere
        asynchronous: true
        sourceComponent:
            PQMinimap {}
    }

    Component.onCompleted: {

        if(PQCConstants.startupFilePath != "") {

            var img = repeaterimage.itemAt(0)

            if(img === null || (PQCScriptsFilesPaths.isFolder(PQCConstants.startupFilePath) && PQCFileFolderModel.countMainView === 0)) {
                loadFirstImage.counter = 0
                loadFirstImage.start()
                return
            }

            if(PQCScriptsFilesPaths.isFolder(PQCConstants.startupFilePath))
                PQCConstants.startupFilePath = (PQCFileFolderModel.countMainView > 0 ? PQCFileFolderModel.entriesMainView[0] : "")

            img.containingFolder = PQCScriptsFilesPaths.getDir(PQCConstants.startupFilePath)
            img.lastModified = PQCScriptsFilesPaths.getFileModified(PQCConstants.startupFilePath).toLocaleString()
            img.imageSource = PQCConstants.startupFilePath
            img.thisIsStartupFile = true

        }

    }

    Timer {
        id: loadFirstImage
        interval: 10
        property int counter: 0
        onTriggered: {
            var img = repeaterimage.itemAt(0)
            if(img === null || (PQCScriptsFilesPaths.isFolder(PQCConstants.startupFilePath) && PQCFileFolderModel.countMainView === 0 && counter < 50)) {
                counter += 1
                loadFirstImage.restart()
                return
            }

            if(PQCScriptsFilesPaths.isFolder(PQCConstants.startupFilePath))
                PQCConstants.startupFilePath = (PQCFileFolderModel.countMainView > 0 ? PQCFileFolderModel.entriesMainView[0] : "")

            img.containingFolder = PQCScriptsFilesPaths.getDir(PQCConstants.startupFilePath)
            img.lastModified = PQCScriptsFilesPaths.getFileModified(PQCConstants.startupFilePath).toLocaleString()
            img.imageSource = PQCConstants.startupFilePath
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

        function onSendShortcutShowNextArcDocImage() {
            image_top.showNextArchiveDocument()
        }

        function onSendShortcutShowPrevArcDocImage() {
            image_top.showPreviousArchiveDocument()
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

        target: PQCFileFolderModel

        function onCurrentIndexChanged() {

            if(PQCConstants.ignoreFileFolderChangesTemporary) {
                console.debug("Ignoring new currentIndex:", PQCFileFolderModel.currentIndex)
                return
            }

            if(PQCFileFolderModel.countMainView === 0) {
                for(var i = 0; i < howManyLoaders; ++i) {
                    var curimg = repeaterimage.itemAt(i)
                    if(curimg.item)
                        curimg.item.hideImage()
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
        interval: PQCSettings.imageviewAnimationDuration*100
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

    function showNextArchiveDocument() {

        if(PQCFileFolderModel.isARC || PQCFileFolderModel.isPDF)
            PQCFileFolderModel.disableViewerMode(false)

        var found = -1
        for(var i = PQCFileFolderModel.currentIndex+1; i < PQCFileFolderModel.countMainView; ++i) {
            if(PQCScriptsImages.isArchive(PQCFileFolderModel.entriesMainView[i]) || PQCScriptsImages.isPDFDocument(PQCFileFolderModel.entriesMainView[i])) {
                found = i
                break
            }
        }
        if(found == -1 && PQCSettings.imageviewLoopThroughFolder) {
            for(var j = 0; j < PQCFileFolderModel.currentIndex; ++j) {
                if(PQCScriptsImages.isArchive(PQCFileFolderModel.entriesMainView[j]) || PQCScriptsImages.isPDFDocument(PQCFileFolderModel.entriesMainView[j])) {
                    found = j
                    break
                }
            }
        }

        if(found != -1) {
            PQCFileFolderModel.currentIndex = found
        }

    }

    function showPreviousArchiveDocument() {

        if(PQCFileFolderModel.isARC || PQCFileFolderModel.isPDF)
            PQCFileFolderModel.disableViewerMode(false)

        var found = -1
        for(var i = PQCFileFolderModel.currentIndex-1; i >= 0; --i) {
            if(PQCScriptsImages.isArchive(PQCFileFolderModel.entriesMainView[i]) || PQCScriptsImages.isPDFDocument(PQCFileFolderModel.entriesMainView[i])) {
                found = i
                break
            }
        }
        if(found == -1 && PQCSettings.imageviewLoopThroughFolder) {
            for(var j = PQCFileFolderModel.countMainView-1; j > PQCFileFolderModel.currentIndex; --j) {
                if(PQCScriptsImages.isArchive(PQCFileFolderModel.entriesMainView[j]) || PQCScriptsImages.isPDFDocument(PQCFileFolderModel.entriesMainView[j])) {
                    found = j
                    break
                }
            }
        }

        if(found != -1)
            PQCFileFolderModel.currentIndex = found

    }

}
