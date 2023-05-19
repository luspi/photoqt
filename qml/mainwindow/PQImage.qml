/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import "./image/"
import "../elements"

Item {

    id: container

    anchors.fill: parent
    anchors.leftMargin: PQSettings.imageviewMargin
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

    signal moveViewLeft()
    signal moveViewRight()
    signal moveViewUp()
    signal moveViewDown()

    signal goToLeftEdge()
    signal goToRightEdge()
    signal goToTopEdge()
    signal goToBottomEdge()

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

    property string currentTransition: "opacity"

    Repeater {

        id: repeat

        anchors.fill: parent

        model: ListModel {
            id: image_model
        }

        delegate: Item {

            id: deleg
            property int imageStatus: Image.Loading
            property size imageDimensions: Qt.size(-1,-1)
            onImageDimensionsChanged: {
                if(container.imageLatestAdded == deleg.uniqueid)
                    variables.currentImageResolution = imageDimensions
            }

            Loader {
                id: imageloader
                property alias imageStatus: deleg.imageStatus
                property alias imageDimensions: deleg.imageDimensions
            }

            // we don't set this here directly as otherwise for some reason the id in Component.onCompleted and here can be different at
            // startup when the image from a previous session is reloaded
            property string uniqueid: ""

            property int hideShowImageIndex: -1

            onImageStatusChanged: {
                if(imageStatus == Image.Ready) {
                    loadingtimer.stop()
                    loadingindicator.visible = false
                    if(variables.chromecastConnected)
                        handlingchromecast.streamOnDevice(src)
                }
                if(imageStatus == Image.Ready && container.imageLatestAdded==deleg.uniqueid) {
                    deleg.hideShowImageIndex = imageIndex
                    deleg.hideShow(true)
                    container.newImageLoaded(deleg.uniqueid)
                }
            }

            Component.onCompleted: {

                uniqueid = handlingGeneral.getUniqueId()

                container.imageLatestAdded = deleg.uniqueid

                loadingindicator.visible = false
                loadingtimer.restart()

                if(PQImageFormats.getEnabledFormatsVideo().indexOf(handlingFileDir.getSuffix(src))>-1 && (!PQSettings.filetypesVideoPreferLibmpv || !handlingGeneral.isMPVSupportEnabled())) {
                    imageloader.source = "image/PQMovie.qml"
                    variables.videoControlsVisible = true
                } else if(PQImageFormats.getEnabledFormatsLibmpv().indexOf(handlingFileDir.getSuffix(src))>-1 && handlingGeneral.isMPVSupportEnabled()) {
                    imageloader.source = "image/PQMPV.qml"
                    variables.videoControlsVisible = true
                } else if(imageproperties.isAnimated(src)) {
                    if(handlingGeneral.amIOnWindows()) {
                        var s = handlingFileDir.copyFileToCacheDir(src)
                        if(s != "")
                            src = s
                    }
                    imageloader.source = "image/PQImageAnimated.qml"
                    variables.videoControlsVisible = false
                } else {
                    imageloader.source = "image/PQImageNormal.qml"
                    variables.videoControlsVisible = false
                }

            }

            Connections {
                target: container

                onHideAllImages:
                    deleg.hideShow(false)

                onNewImageLoaded: {
                    if(id != deleg.uniqueid) {
                        if(deleg.getHideShowRunning())
                            deleg.hideShowContinueDeletingAfterShowing()
                        else {
                            if(deleg.imageStatus == Image.Ready) {
                                // store pos/zoom/rotation/mirror, can be restored when setting enabled
                                imageloader.item.storePosRotZoomMirror()
                                deleg.hideShow(false)
                            } else {
                                for(var i = image_model.count-2; i >= 0; --i)
                                    image_model.remove(i)
                            }
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowOpacity
                target: deleg
                property: "opacity"
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property bool handleStoppedAni: false

                function startAni() {

                    if(showing) {

                        from = 0
                        to = 1

                    } else {

                        from = 1
                        to = 0

                    }

                    start()

                }

                onStopped: {
                    if(handleStoppedAni) {
                        if(!showing) {
                            // we always leave the current and previous image in the model to allow for animations
                            if(image_model.count > 2)
                                image_model.remove(0,image_model.count-2)
                        } else if(continueToDeleteAfterShowing) {
                            showing = false
                            startAni()
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowX
                target: deleg
                property: "x"
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property bool handleStoppedAni: false

                function startAni() {

                    var hideshow = ""

                    if(showing) {
                        if(deleg.hideShowImageIndex >= container.currentlyShownIndex)
                            hideshow = "left"
                        else
                            hideshow = "right"

                        container.currentlyShownIndex = deleg.hideShowImageIndex

                    } else {
                        if(deleg.hideShowImageIndex >= container.currentlyShownIndex)
                            hideshow = "right"
                        else
                            hideshow = "left"
                    }

                    if(showing) {

                        if(hideshow == "left") {
                            from = container.width
                            to = PQSettings.imageviewMargin
                        } else {
                            from = -container.width
                            to = PQSettings.imageviewMargin
                        }

                    } else {

                        if(hideshow == "left") {
                            from = deleg.x
                            to = -container.width
                        } else {
                            from = deleg.x
                            to = container.width
                        }

                    }

                    start()

                }

                onStopped: {
                    if(handleStoppedAni) {
                        if(!showing) {
                            image_model.remove(0,image_model.count-1)
                        } else if(continueToDeleteAfterShowing) {
                            showing = false
                            startAni()
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowY
                target: deleg
                property: "y"
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property bool handleStoppedAni: false

                function startAni() {

                    var hideshow = ""

                    if(showing) {
                        if(deleg.hideShowImageIndex >= container.currentlyShownIndex)
                            hideshow = "top"
                        else
                            hideshow = "bottom"

                        container.currentlyShownIndex = deleg.hideShowImageIndex

                    } else {
                        if(deleg.hideShowImageIndex >= container.currentlyShownIndex)
                            hideshow = "bottom"
                        else
                            hideshow = "top"
                    }

                    if(showing) {

                        if(hideshow == "top") {
                            from = container.height
                            to = PQSettings.imageviewMargin
                        } else {
                            from = -container.height
                            to = PQSettings.imageviewMargin
                        }

                    } else {

                        if(hideshow == "top") {
                            from = deleg.x
                            to = -container.height
                        } else {
                            from = deleg.x
                            to = container.height
                        }

                    }

                    start()

                }

                onStopped: {
                    if(handleStoppedAni) {
                        if(!showing) {
                            image_model.remove(0,image_model.count-1)
                        } else if(continueToDeleteAfterShowing) {
                            showing = false
                            startAni()
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowScale
                target: imageloader
                property: "scale"
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property bool handleStoppedAni: false

                property bool implode: false

                function startAni() {

                    if(implode) {

                        if(showing) {

                            from = 0.0
                            to = 1

                        } else {

                            from = 1
                            to = 0.0

                        }

                    } else {

                        if(showing) {

                            from = 2
                            to = 1

                        } else {

                            from = 1
                            to = 2

                        }

                    }

                    start()

                }

                onStopped: {
                    if(handleStoppedAni) {
                        if(!showing) {
                            image_model.remove(0,image_model.count-1)
                        } else if(continueToDeleteAfterShowing) {
                            showing = false
                            startAni()
                        }
                    }
                }

            }

            PropertyAnimation {
                id: hideShowRotation
                target: imageloader
                property: "rotation"
                duration: PQSettings.imageviewAnimationDuration*100
                property bool showing: true
                property bool continueToDeleteAfterShowing: false
                alwaysRunToEnd: true

                property bool handleStoppedAni: false

                function startAni() {

                    if(showing) {

                        from = 360
                        to = 0

                    } else {

                        from = variables.currentRotationAngle
                        to = variables.currentRotationAngle+360

                    }

                    start()

                }

                onStopped: {
                    if(handleStoppedAni) {
                        if(!showing) {
                            image_model.remove(0,image_model.count-1)
                        } else if(continueToDeleteAfterShowing) {
                            showing = false
                            startAni()
                        }
                    }
                }

            }

            function hideShow(showing) {

                var anim = PQSettings.imageviewAnimationType

                if(anim == "opacity")
                    hideShowExecOpacity(showing)

                if(anim == "x")
                    hideShowExecX(showing)

                if(anim == "y")
                    hideShowExecY(showing)

                if(anim == "explosion")
                    hideShowExecExplosion(showing)

                if(anim == "implosion")
                    hideShowExecImplosion(showing)

                if(anim == "rotation")
                    hideShowExecRotation(showing)

                if(anim == "random") {

                    if(currentTransition == "opacity")
                        hideShowExecOpacity(showing)

                    if(currentTransition == "x")
                        hideShowExecX(showing)

                    if(currentTransition == "y")
                        hideShowExecY(showing)

                    if(currentTransition == "explosion")
                        hideShowExecExplosion(showing)

                    if(currentTransition == "implosion")
                        hideShowExecImplosion(showing)

                    if(currentTransition == "rotation")
                        hideShowExecRotation(showing)

                    selectNewCurTransition.restart()

                }

            }

            Timer {
                id: selectNewCurTransition
                interval: hideShowRotation.duration/2
                running: false
                repeat: false
                onTriggered: {
                    var animValues = ["opacity","x","y","explosion","implosion","rotation"]
                    currentTransition = animValues[Math.floor(Math.random()*animValues.length)]
                }
            }

            function hideShowExecOpacity(showing) {

                hideShowOpacity.showing = showing
                hideShowOpacity.handleStoppedAni = true
                hideShowOpacity.startAni()

            }

            function hideShowExecX(showing) {

                hideShowX.showing = showing
                hideShowX.handleStoppedAni = true
                hideShowX.startAni()

            }

            function hideShowExecY(showing) {

                hideShowY.showing = showing
                hideShowY.handleStoppedAni = true
                hideShowY.startAni()

            }

            function hideShowExecExplosion(showing) {

                hideShowOpacity.showing = showing
                hideShowOpacity.handleStoppedAni = false

                if(!showing) {

                    hideShowScale.showing = showing
                    hideShowScale.handleStoppedAni = true
                    hideShowScale.startAni()
                    hideShowOpacity.startAni()

                } else

                    hideShowOpacity.startAni()
            }


            function hideShowExecImplosion(showing) {

                if(!showing) {

                    hideShowScale.showing = showing
                    hideShowScale.handleStoppedAni = true
                    hideShowScale.implode = true
                    hideShowScale.startAni()

                } else {

                    hideShowOpacity.showing = showing
                    hideShowOpacity.handleStoppedAni = true
                    hideShowOpacity.startAni()

                }
            }

            function hideShowExecRotation(showing) {

                hideShowOpacity.showing = showing
                hideShowOpacity.handleStoppedAni = false

                hideShowRotation.showing = showing
                hideShowRotation.handleStoppedAni = true

                hideShowOpacity.startAni()
                hideShowRotation.startAni()
            }



            function getHideShowRunning() {

                if(currentTransition == "opacity")
                    return hideShowOpacity.running

                if(currentTransition == "x")
                    return hideShowX.running

                if(currentTransition == "y")
                    return hideShowY.running

                if(currentTransition == "explosion")
                    return (hideShowOpacity.running||hideShowScale.running)

                if(currentTransition == "implosion")
                    return (hideShowOpacity.running||hideShowScale.running)

                if(currentTransition == "rotation")
                    return (hideShowOpacity.running||hideShowRotation.running)

            }

            function hideShowContinueDeletingAfterShowing() {

                if(currentTransition == "opacity")
                    hideShowOpacity.continueToDeleteAfterShowing = true

                if(currentTransition == "x")
                    hideShowX.continueToDeleteAfterShowing = true

                if(currentTransition == "y")
                    hideShowY.continueToDeleteAfterShowing = true

                if(currentTransition == "explosion") {
                    hideShowOpacity.continueToDeleteAfterShowing = true
                    hideShowScale.continueToDeleteAfterShowing = true
                }

                if(currentTransition == "implosion") {
                    hideShowOpacity.continueToDeleteAfterShowing = true
                    hideShowScale.continueToDeleteAfterShowing = true
                }

                if(currentTransition == "rotation") {
                    hideShowOpacity.continueToDeleteAfterShowing = true
                    hideShowRotation.continueToDeleteAfterShowing = true
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
            mipmap: true
            sourceSize: Qt.size(width, height)
            source: "/image/viewermode.svg"
        }

        PQMouseArea {
            id: viewermodemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: em.pty+qsTranslate("quickinfo", "Click here to enter viewer mode")
            onClicked:
                statusinfo.enterViewerMode()
        }

        Image {
            x: parent.width-width
            y: 0
            width: 30
            height: 30
            opacity: viewermodebutmousehide.containsMouse ? 0.5 : 0.25
            Behavior on opacity { NumberAnimation { duration: 300 } }
            source: "/other/close.svg"
            sourceSize: Qt.size(width, height)
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
        onIsARCChanged: {
            if(filefoldermodel.isARC) {
                viewermodemouse.enabled = false
                hidebut1.start()
                hidebut2.start()
            }
        }
        onIsPQTChanged: {
            if(filefoldermodel.isPQT) {
                viewermodemouse.enabled = false
                hidebut1.start()
                hidebut2.start()
            }
        }
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

    function loadRandomImage() {
        if(filefoldermodel.countMainView == 0 || filefoldermodel.countMainView == 1)
            return
        // special case: load other image
        if(filefoldermodel.countMainView == 2)
            filefoldermodel.current = (filefoldermodel.current+1)%2
        // find new image that's not the current one (if possible)
        var ran = filefoldermodel.current
        var iter = 0
        while(ran == filefoldermodel.current) {
            ran = Math.floor(Math.random() * filefoldermodel.countMainView);
            iter += 1
            if(iter > 100)
                break
        }
        filefoldermodel.current = ran
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

    function resetImageView() {
        repeat.model.clear()
    }

}
