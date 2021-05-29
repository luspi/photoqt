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
    anchors.leftMargin: variables.metaDataWidthWhenKeptOpen
    Behavior on anchors.leftMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    anchors.bottomMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition!="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive & !variables.faceTaggingActive) ? thumbnails.height : 0
    Behavior on anchors.bottomMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    anchors.topMargin: ((PQSettings.thumbnailKeepVisible || PQSettings.thumbnailKeepVisibleWhenNotZoomedIn) && PQSettings.thumbnailPosition=="Top" && !PQSettings.thumbnailDisable && !variables.slideShowActive && !variables.faceTaggingActive) ? thumbnails.height : 0
    Behavior on anchors.topMargin { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    signal zoomIn()
    signal zoomOut()
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

    property bool justAfterStartup: true
    Timer {
        running: true
        repeat: false
        interval: 250
        onTriggered: justAfterStartup = false
    }

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
                            } else
                                image_model.remove(index)
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowAni
                target: deleg
                property: PQSettings.animationType
                duration: PQSettings.animationDuration*100
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

                        if(PQSettings.animationType == "x") {

                            if(hideshow == "left") {
                                from = container.width
                                to = PQSettings.marginAroundImage
                            } else {
                                from = -container.width
                                to = PQSettings.marginAroundImage
                            }

                        } else if(PQSettings.animationType == "y") {

                            if(hideshow == "left") {
                                from = container.height
                                to = PQSettings.marginAroundImage
                            } else {
                                from = -container.height
                                to = PQSettings.marginAroundImage
                            }

                        // we default to opacity
                        } else {
                            from = 0
                            to = 1
                        }

                    } else {

                        if(PQSettings.animationType == "x") {

                            if(hideshow == "left") {
                                from = deleg.x
                                to = -container.width
                            } else {
                                from = deleg.x
                                to = container.width
                            }

                        } else if(PQSettings.animationType == "y") {

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
                        image_model.remove(index)
                    } else if(continueToDeleteAfterShowing) {
                        showing = false
                        startAni()
                    }
                }

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

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged:
            loadNewFile()
    }

    function loadNewFile() {
        variables.currentRotationAngle = 0
        if(filefoldermodel.current > -1 && filefoldermodel.current < filefoldermodel.countMainView) {
            var src = handlingFileDir.cleanPath(filefoldermodel.currentFilePath)
            image_model.append({"src" : src, "imageIndex" : filefoldermodel.current})
        } else if(filefoldermodel.current == -1 || filefoldermodel.countMainView == 0)
            hideAllImages()
    }

    function loadNextImage() {
        if(filefoldermodel.current < filefoldermodel.countMainView-1)
            ++filefoldermodel.current
        else if(filefoldermodel.current == filefoldermodel.countMainView-1 && PQSettings.loopThroughFolder)
            filefoldermodel.current = 0
    }

    function loadPrevImage() {
        if(filefoldermodel.current > 0)
            --filefoldermodel.current
        else if(filefoldermodel.current == 0 && PQSettings.loopThroughFolder)
            filefoldermodel.current = filefoldermodel.countMainView-1
    }

    function loadFirstImage() {
        filefoldermodel.current = 0
    }

    function loadLastImage() {
        filefoldermodel.current = filefoldermodel.countMainView-1
    }

    function playPauseAnimation() {
        container.playPauseAnim()
    }

    function getCurrentVideoLength() {
        return currentVideoLength
    }

}
