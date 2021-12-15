/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.9
import QtGraphicalEffects 1.0
import "./image/"
import "../elements"

Item {

    id: container

    anchors.fill: parent
    anchors.leftMargin: PQSettings.imageviewMargin+ variables.metaDataWidthWhenKeptOpen
    Behavior on anchors.leftMargin { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    // ThumbnailsVisibility
    // 0 = on demand
    // 1 = always
    // 2 = except when zoomed

    anchors.bottomMargin: ((PQSettings.thumbnailsVisibility==1 || PQSettings.thumbnailsVisibility==2) && PQSettings.thumbnailsEdge!="Top" && !PQSettings.thumbnailsDisable && !variables.slideShowActive & !variables.faceTaggingActive) ? PQSettings.imageviewMargin+thumbnails.height : PQSettings.imageviewMargin
    Behavior on anchors.bottomMargin { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    anchors.topMargin: ((PQSettings.thumbnailsVisibility==1 || PQSettings.thumbnailsVisibility==2) && PQSettings.thumbnailsEdge=="Top" && !PQSettings.thumbnailsDisable && !variables.slideShowActive && !variables.faceTaggingActive) ? PQSettings.imageviewMargin+thumbnails.height : PQSettings.imageviewMargin
    Behavior on anchors.topMargin { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    anchors.rightMargin: PQSettings.imageviewMargin

    signal zoomIn(var wheelDelta)
    signal zoomOut(var wheelDelta)
    signal zoomReset()
    signal zoomActual()
    signal rotate(var deg)
    signal rotateReset()
    signal mirrorH()
    signal mirrorV()
    signal mirrorReset()

    signal playPauseAnim()
    signal playAnim()
    signal pauseAnim()
    signal restartAnim()

    signal hideAllImages()

    // emitted inside of PQImageNormal/Animated whenever its status changed to Image.Reader
    signal newImageLoaded(var id)

    // id
    property string imageLatestAdded: ""

    // currently shown index
    property int currentlyShownIndex: -1

    property int currentVideoLength: -1

    Repeater {

        id: repeat

        anchors.fill: parent

        model: ListModel {
            id: image_model
        }

        delegate: Item {

            id: deleg
            property int imageStatus: Image.Loading

            Loader {
                id: imageloader
                property alias imageStatus: deleg.imageStatus
            }

            property string uniqueid: handlingGeneral.getUniqueId()

            onImageStatusChanged: {
                if(imageStatus == Image.Ready) {
                    loadingtimer.stop()
                    loadingindicator.visible = false
                    if(variables.chromecastConnected)
                        handlingchromecast.streamOnDevice(src)
                }
                if(imageStatus == Image.Ready && container.imageLatestAdded==deleg.uniqueid) {
                    hideShowAni.showing = true
                    hideShowAni.imageIndex = imageIndex
                    hideShowAni.startAni()
                    container.newImageLoaded(deleg.uniqueid)
                }
            }

            Component.onCompleted: {

                container.imageLatestAdded = deleg.uniqueid

                loadingindicator.visible = false
                loadingtimer.restart()

                if(PQImageFormats.getEnabledFormatsVideo().indexOf(handlingFileDir.getSuffix(src))>-1) {
                    imageloader.source = "image/PQMovie.qml"
                    variables.videoControlsVisible = true
                } else if(imageproperties.isAnimated(src)) {
                    imageloader.source = "image/PQImageAnimated.qml"
                    variables.videoControlsVisible = false
                } else {
                    imageloader.source = "image/PQImageNormal.qml"
                    variables.videoControlsVisible = false
                }

            }

            Connections {
                target: container

                onHideAllImages: {
                    hideShowAni.showing = false
                    hideShowAni.startAni()
                }

                onNewImageLoaded: {
                    if(id != deleg.uniqueid) {
                        if(hideShowAni.running) {
                            if(hideShowAni.showing)
                                hideShowAni.continueToDeleteAfterShowing = true
                        } else {
                            if(deleg.imageStatus == Image.Ready) {
                                hideShowAni.showing = false
                                // store pos/zoom/rotation/mirror, can be restored when setting enabled
                                imageloader.item.storePosRotZoomMirror()
                                hideShowAni.startAni()
                            } else {
                                for(var i = image_model.count-2; i >= 0; --i)
                                    image_model.remove(i)
                            }
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowAni
                target: deleg
                property: PQSettings.imageviewAnimationType
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property int imageIndex: -1

                function startAni() {

                    var hideshow = ""

                    if(showing) {
                        if(imageIndex >= container.currentlyShownIndex)
                            hideshow = "left"
                        else
                            hideshow = "right"

                        container.currentlyShownIndex = imageIndex

                    } else {
                        if(imageIndex >= container.currentlyShownIndex)
                            hideshow = "right"
                        else
                            hideshow = "left"
                    }

                    if(showing) {

                        if(PQSettings.imageviewAnimationType == "x") {

                            if(hideshow == "left") {
                                from = container.width
                                to = PQSettings.imageviewMargin
                            } else {
                                from = -container.width
                                to = PQSettings.imageviewMargin
                            }

                        } else if(PQSettings.imageviewAnimationType == "y") {

                            if(hideshow == "left") {
                                from = container.height
                                to = PQSettings.imageviewMargin
                            } else {
                                from = -container.height
                                to = PQSettings.imageviewMargin
                            }

                        // we default to opacity
                        } else {
                            from = 0
                            to = 1
                        }

                    } else {

                        if(PQSettings.imageviewAnimationType == "x") {

                            if(hideshow == "left") {
                                from = deleg.x
                                to = -container.width
                            } else {
                                from = deleg.x
                                to = container.width
                            }

                        } else if(PQSettings.imageviewAnimationType == "y") {

                            if(hideshow == "left") {
                                from = deleg.x
                                to = -container.height
                            } else {
                                from = deleg.x
                                to = container.height
                            }

                        // we default to opacity
                        } else {
                            from = 1
                            to = 0
                        }

                    }

                    start()

                }

                onStopped: {
                    if(!showing) {
                        for(var i = image_model.count-2; i >= 0; --i)
                            image_model.remove(i)
                    } else if(continueToDeleteAfterShowing) {
                        showing = false
                        startAni()
                    }
                }

            }

        }

    }

    // a big button in middle of screen to enter 'viewer mode'
    Rectangle {
        id: viewermodebut
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: 300
        height: 300
        color: "#cc000000"
        radius: 10
        opacity: viewermodemouse.containsMouse||viewermodebutmousehide.containsMouse ? 1 : 0.5
        Behavior on opacity { NumberAnimation { duration: 300 } }

        property bool viewermodeavailable: ( imageproperties.isPopplerDocument(filefoldermodel.currentFilePath) &&
                                            (imageproperties.getDocumentPages(filefoldermodel.currentFilePath)>1 || filefoldermodel.isPQT))
                                                  || (imageproperties.isArchive(filefoldermodel.currentFilePath))
        property bool notinside: true

        visible: PQSettings.imageviewBigViewerModeButton && viewermodeavailable && notinside

        Connections {
            target: filefoldermodel
            onIsPQTChanged: {
                if(!filefoldermodel.isPQT && !filefoldermodel.isARC)
                    viewermodebut.notinside = true
            }
            onIsARCChanged: {
                if(!filefoldermodel.isPQT && !filefoldermodel.isARC)
                    viewermodebut.notinside = true
            }
        }

        PropertyAnimation {
            id: hidebut1
            target: viewermodebut
            properties: "width,height"
            from: 300
            to: Math.min(container.width, container.height)
            duration: 400
        }

        PropertyAnimation {
            id: hidebut2
            target: viewermodebut
            property: "opacity"
            from: 1
            to: 0
            duration: 400
            onStopped: {
                viewermodemouse.enabled = true
                viewermodebut.notinside = false
                viewermodebut.width = 300
                viewermodebut.height = 300
                viewermodebut.opacity = Qt.binding(function() { if(viewermodemouse.containsMouse || viewermodebutmousehide.containsMouse) return 1; return 0.5; })
            }
        }

        Image {
            anchors.fill: parent
            anchors.margins: 40
            source: "/image/viewermode.png"
        }

        PQMouseArea {
            id: viewermodemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: em.pty+qsTranslate("quickinfo", "Click here to enter viewer mode")
            onClicked: {
                viewermodemouse.enabled = false
                hidebut1.start()
                hidebut2.start()
                labels.enterViewerMode()
            }
        }

        Image {
            x: parent.width-width+10
            y: -10
            width: 30
            height: 30
            opacity: viewermodebutmousehide.containsMouse ? 0.5 : 0.25
            Behavior on opacity { NumberAnimation { duration: 300 } }
            source: "/other/histogramclose.png"
            PQMouseArea {
                id: viewermodebutmousehide
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Hide central 'viewer mode' button")
                onClicked: PQSettings.imageviewBigViewerModeButton = false
            }
        }

    }

    Timer {
        id: loadingtimer
        interval: 500
        running: false
        repeat: false
        onTriggered:
            loadingindicator.visible = true
    }

    PQLoading { id: loadingindicator }

    PQFaceTagsUnsupported {
        id: facetagsunsupported
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged:
            loadNewFile()
    }

    Connections {
        target: filewatcher
        onCurrentFileChanged:
            loadNewFile()
    }

    function loadNewFile() {
        variables.currentRotationAngle = 0
        if(filefoldermodel.current > -1 && filefoldermodel.current < filefoldermodel.countMainView) {
            var src = handlingFileDir.cleanPath(filefoldermodel.currentFilePath)
            image_model.append({"src" : src, "imageIndex" : filefoldermodel.current})
            filewatcher.setCurrentFile(src)
        } else if(filefoldermodel.current == -1 || filefoldermodel.countMainView == 0) {
            hideAllImages()
            filewatcher.setCurrentFile("")
        }
    }

    function loadNextImage() {
        if(filefoldermodel.countMainView == 0)
            return
        if(filefoldermodel.current < filefoldermodel.countMainView-1)
            ++filefoldermodel.current
        else if(filefoldermodel.current == filefoldermodel.countMainView-1 && PQSettings.imageviewLoopThroughFolder)
            filefoldermodel.current = 0
    }

    function loadPrevImage() {
        if(filefoldermodel.countMainView == 0)
            return
        if(filefoldermodel.current > 0)
            --filefoldermodel.current
        else if(filefoldermodel.current == 0 && PQSettings.imageviewLoopThroughFolder)
            filefoldermodel.current = filefoldermodel.countMainView-1
    }

    function loadFirstImage() {
        if(filefoldermodel.countMainView == 0)
            return
        filefoldermodel.current = 0
    }

    function loadLastImage() {
        if(filefoldermodel.countMainView == 0)
            return
        filefoldermodel.current = filefoldermodel.countMainView-1
    }

    function playPauseAnimation() {
        container.playPauseAnim()
    }

    function getCurrentVideoLength() {
        return currentVideoLength
    }

}
