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
import "../../elements"

Item {

    id: cont
    x: useStoredData ? variables.zoomRotationMirror[src][4].x : 0
    y: useStoredData ? variables.zoomRotationMirror[src][4].y : 0
    width: container.width
    height: container.height

    property real defaultScale: 1.0
    property bool useStoredData: PQSettings.imageviewRememberZoomRotationMirror && src in variables.zoomRotationMirror

    // large images can cause flickering when transitioning before scale is reset
    // this makes that invisible
    // this is set to true *after* proper scale has been set
    visible: false

    property bool reloadingImage: false

    AnimatedImage {

        id: theimage
        property real curX: useStoredData ? variables.zoomRotationMirror[src][0].x : 0
        property real curY: useStoredData ? variables.zoomRotationMirror[src][0].y : 0
        x: curX
        y: curY
        width: sourceSize.width
        height: sourceSize.height
        fillMode: Image.Pad
        clip: true
        cache: false
        asynchronous: true

        property bool storePlaying: playing

        source: "file:///" + handlingGeneral.toPercentEncoding(src)

        mirror: useStoredData ? variables.zoomRotationMirror[src][3] : false

        smooth: true

        rotation: useStoredData ? variables.zoomRotationMirror[src][1] : 0
        property real rotateTo: 0.0
        onRotateToChanged: {
            rotation = rotateTo
            if(theimage.curScale == defaultScale && curX == 0 && curY == 0) {
                reset(true, false)
            }
        }
        onRotationChanged: {
            if(!rotani.running)
                rotateTo = rotation
            variables.currentRotationAngle = rotation
        }

        property real curScale: useStoredData ? variables.zoomRotationMirror[src][2] : 1
        scale: curScale
        onScaleChanged: {
            variables.currentZoomLevel = theimage.scale*100
            variables.currentPaintedZoomLevel = theimage.scale
        }

        onStatusChanged: {
            if(source == "") return
            cont.parent.imageStatus = status
            if(status == Image.Ready) {
                if(reloadingImage) {
                    loadingindicator.forceStop()
                    reloadingImage = false
                } else
                    theimage_load.restart()
                if(sourceSize.width > 0 && sourceSize.height > 0)
                    cont.parent.imageDimensions = sourceSize
                else
                    cont.parent.imageDimensions = imageproperties.getImageResolution(src)
            }
        }

        Behavior on x { NumberAnimation { id: xani; duration: PQSettings.imageviewAnimationDuration*100  } }
        Behavior on y { NumberAnimation { id: yani; duration: PQSettings.imageviewAnimationDuration*100  } }
        Behavior on rotation { NumberAnimation { id: rotani; duration: PQSettings.imageviewAnimationDuration*100  } }
        // its duration it set to proper value after image has been loaded properly (in reset())
        Behavior on scale { NumberAnimation { id: scaleani; duration: PQSettings.imageviewAnimationDuration*100  } }

        Image {
            anchors.fill: parent
            z: -1
            smooth: false
            visible: PQSettings.imageviewTransparencyMarker
            source: PQSettings.imageviewTransparencyMarker ? "/image/checkerboard.png" : ""
            sourceSize.width: Math.max(10, Math.min((parent.height/50), (parent.width/50)))
            fillMode: Image.Tile
        }

        Timer {
            id: theimage_load
            interval: 0
            repeat: false
            running: false
            onTriggered: {
                if(!useStoredData) {
                    xani.duration = 0
                    yani.duration = 0
                    scaleani.duration = 0

                    reset(true, true)

                    xani.duration = PQSettings.imageviewAnimationDuration*100
                    yani.duration = PQSettings.imageviewAnimationDuration*100
                    scaleani.duration = PQSettings.imageviewAnimationDuration*100

                }
                cont.visible = true
                variables.viewChanged = false
            }
        }

    }

    PQMouseArea {
        id: bgmouse
        x: -cont.x
        y: -cont.y
        width: container.width
        height: container.height
        hoverEnabled: false
        onClicked: {
            // a double click on the image also fires this signal
            // we must check the location of this click on ignore it if inside image
            var imgpos = theimage.mapFromItem(bgmouse, mouse.x, mouse.y)
            if((imgpos.x >= 0 && imgpos.x <= theimage.paintedWidth) &&
                    (imgpos.y >= 0 && imgpos.y <= theimage.paintedHeight))
                return
            if(PQSettings.interfaceCloseOnEmptyBackground)
                toplevel.close()
            else if(PQSettings.interfaceNavigateOnEmptyBackground) {
                if(mouse.x < width/2)
                    imageitem.loadPrevImage()
                else
                    imageitem.loadNextImage()
            } else if(PQSettings.interfaceWindowDecorationOnEmptyBackground)
                PQSettings.interfaceWindowDecoration = !PQSettings.interfaceWindowDecoration
        }
    }

    PinchArea {

        id: pincharea

        anchors.fill: theimage

        scale: theimage.scale
        rotation: theimage.rotation

        // the actual scale factor from a pinch event is the initial scale multiplied by Pinch.scale
        property real initialScale
        onPinchStarted: {
            variables.viewChanged = true
            initialScale = theimage.curScale
            contextmenu.hideMenu()
        }

        onPinchUpdated: {

            // disable animations for the pinching
            xani.duration = 0
            yani.duration = 0
            scaleani.duration = 0

            // pinchto the center position of the pinch
            performZoom(theimage.mapFromItem(pincharea, pinch.center.x, pinch.center.y), undefined, false, false, true, (initialScale*pinch.scale)/theimage.curScale)

            // re-enable animations after the pinching
            xani.duration = PQSettings.imageviewAnimationDuration*100
            yani.duration = PQSettings.imageviewAnimationDuration*100
            scaleani.duration = PQSettings.imageviewAnimationDuration*100
        }

        PQMouseArea {
            id: mousearea
            enabled: !facetagger.visible&&!variables.slideShowActive
            anchors.fill: parent

            doubleClickThreshold: PQSettings.interfaceDoubleClickThreshold

            drag.target: theimage
            drag.onActiveChanged:
                variables.viewChanged = true

            hoverEnabled: false // important, otherwise the mouse pos will not be caught globally!

            propagateComposedEvents: true

            property point pressedPos

            onPressed:
                pressedPos = Qt.point(mouse.x, mouse.y)

            onPressAndHold: {
                if(Math.sqrt(Math.pow(mouse.x-pressedPos.x, 2) + Math.pow(mouse.y-pressedPos.y)) > 50)
                    return
                variables.mousePos = mousearea.mapToItem(toplevel_bg, mouse.x, mouse.y)
                contextmenu.showMenu()
            }

            onWheel: {
                if(PQSettings.imageviewUseMouseWheelForImageMove && wheel.modifiers==Qt.NoModifier) {
                    variables.viewChanged = true
                    theimage.curX += wheel.angleDelta.x
                    theimage.curY += wheel.angleDelta.y
                } else
                    wheel.accepted = false
            }

            onClicked:
                contextmenu.hideMenu()

            onDoubleClicked:
                mainmousearea.gotDoubleClick(mouse)

            onReleased: {
                theimage.curX = theimage.x
                theimage.curY = theimage.y
                theimage.x = Qt.binding(function() { return theimage.curX })
                theimage.y = Qt.binding(function() { return theimage.curY })
            }

            Connections {
                target: variables
                onMousePosChanged: {
                    if(PQSettings.imageviewHideCursorTimeout > 0)
                        hidecursor.restart()
                    mousearea.cursorShape = Qt.ArrowCursor
                }
                onVisibleItemChanged: {
                    if(variables.visibleItem != "") {
                        hidecursor.stop()
                        mousearea.cursorShape = Qt.ArrowCursor
                        theimage.storePlaying = theimage.playing
                        theimage.playing = false
                    } else {
                        if(PQSettings.imageviewHideCursorTimeout > 0)
                            hidecursor.restart()
                        mousearea.cursorShape = Qt.ArrowCursor
                        theimage.playing = theimage.storePlaying
                    }
                }
            }

            Timer {
                id: hidecursor
                interval: PQSettings.imageviewHideCursorTimeout*1000
                repeat: false
                running: true
                onTriggered: {
                    if(PQSettings.imageviewHideCursorTimeout == 0)
                        return
                    if(contextmenu.isOpen)
                        hidecursor.restart()
                    else
                        mousearea.cursorShape = Qt.BlankCursor
                }
            }

        }

    }

    PQFaceTracker {
        id: facetracker
        anchors.fill: theimage
        scale: theimage.scale
        rotation: theimage.rotation
        filename: src
        visible: !facetagger.visible
        Connections {
            target: facetagger
            onHasBeenUpdated:
                facetracker.updateData()
        }
    }

    PQFaceTagger {
        id: facetagger
        anchors.fill: theimage
        scale: theimage.scale
        rotation: theimage.rotation
        filename: src
    }

    Connections {
        target: toplevel
        onWidthChanged: {
            widthHeightChanged.interval = 10
            widthHeightChanged.start()
        }
        onHeightChanged: {
            widthHeightChanged.interval = 10
            widthHeightChanged.start()
        }
    }

    Connections {
        target: container
        onWidthChanged: {
            widthHeightChanged.interval = PQSettings.imageviewAnimationDuration*100
            widthHeightChanged.start()
        }
        onHeightChanged: {
            widthHeightChanged.interval = PQSettings.imageviewAnimationDuration*100
            widthHeightChanged.start()
        }
    }

    Timer {
        id: widthHeightChanged
        interval: 10
        repeat: false
        running: false
        onTriggered: {
            if(!useStoredData) {
                if(theimage.curX == 0 && theimage.curY && theimage.curScale == defaultScale)
                    reset(true, true)
                else if(theimage.curX == 0 && theimage.curY)
                    reset(false, true)
            }
        }
    }

    Connections {
        target: container
        onZoomIn: {

            // zoom to local mouse position
            // if wheelDelta is undefined, then the zoom happened from a key shortcut
            // in that case we zoom to the screen center
            if(wheelDelta != undefined && !PQSettings.imageviewZoomToCenter)
                performZoom(theimage.mapFromItem(toplevel_bg, variables.mousePos.x, variables.mousePos.y), undefined, true, false, false)
            else
                performZoom(theimage.mapFromItem(toplevel_bg, toplevel.width/2, toplevel.height/2), undefined, true, false, false)

        }
        onZoomOut: {

            // zoom to local mouse position
            // if wheelDelta is undefined, then the zoom happened from a key shortcut
            // in that case we zoom to the screen center
            if(wheelDelta != undefined && !PQSettings.imageviewZoomToCenter)
                performZoom(theimage.mapFromItem(toplevel_bg, variables.mousePos.x, variables.mousePos.y), undefined, false, false, false)
            else
                performZoom(theimage.mapFromItem(toplevel_bg, toplevel.width/2, toplevel.height/2), undefined, false, false, false)

        }
        onZoomReset: {
            reset(true, true)
        }
        onZoomActual: {

            if(variables.currentZoomLevel == 100)
                return

            // zoom to center of screen
            performZoom(theimage.mapFromItem(toplevel_bg, toplevel.width/2, toplevel.height/2), undefined, false, true, false)

        }
        onRotate: {
            variables.viewChanged = true
            theimage.rotateTo += deg
        }
        onRotateReset: {
            var old = theimage.rotateTo%360
            if(old > 0) {
                if(old <= 180)
                    theimage.rotateTo -= old
                else
                    theimage.rotateTo += 360-old
            } else if(old < 0) {
                if(old >= -180)
                    theimage.rotateTo -= old
                else
                    theimage.rotateTo -= (old+360)
            }
            if(theimage.curX == 0 && theimage.curY == 0 && theimage.curScale == defaultScale)
                variables.viewChanged = false
        }
        onMirrorH: {
            variables.viewChanged = true
            var old = theimage.mirror
            theimage.mirror = !old
        }
        onMirrorV: {
            variables.viewChanged = true
            var old = theimage.mirror
            theimage.mirror = !old
            rotani.duration = 0
            theimage.rotateTo += 180
            rotani.duration = PQSettings.imageviewAnimationDuration*100
        }
        onMirrorReset: {
            theimage.mirror = false
        }
        onPlayPauseAnim: {
            theimage.playing = !theimage.playing
        }

        onMoveImageByMouse: {
            variables.viewChanged = true
            theimage.curX += angleDelta.x
            theimage.curY += angleDelta.y
        }

        onMoveViewLeft: {
            variables.viewChanged = true
            theimage.curX += 100
        }
        onMoveViewRight: {
            variables.viewChanged = true
            theimage.curX -= 100
        }
        onMoveViewUp: {
            variables.viewChanged = true
            theimage.curY += 100
        }
        onMoveViewDown: {
            variables.viewChanged = true
            theimage.curY -= 100
        }
        onGoToLeftEdge: {
            variables.viewChanged = true
            if(theimage.paintedWidth*theimage.curScale <= container.width)
                return
            theimage.curX = (theimage.width/2)*theimage.curScale - ((container.width-2*PQSettings.imageviewMargin)/2)
        }
        onGoToRightEdge: {
            variables.viewChanged = true
            if(theimage.paintedWidth*theimage.curScale <= container.width)
                return
            theimage.curX = -(theimage.width/2)*theimage.curScale + ((container.width-PQSettings.imageviewMargin)/2)
        }
        onGoToTopEdge: {
            variables.viewChanged = true
            if(theimage.paintedHeight*theimage.curScale <= container.height)
                return
            theimage.curY = (theimage.height/2)*theimage.curScale - ((container.height-2*PQSettings.imageviewMargin)/2)
        }
        onGoToBottomEdge: {
            variables.viewChanged = true
            if(theimage.paintedHeight*theimage.curScale <= container.height)
                return
            theimage.curY = -(theimage.height/2)*theimage.curScale + ((container.height-PQSettings.imageviewMargin)/2)
        }
    }

    Connections {
        target: PQSettings
        onImageviewFitInWindowChanged: {
            if(theimage.curScale == defaultScale && theimage.curX == 0 && theimage.curY == 0)
                reset(true, false)
        }
        onImageviewAlwaysActualSizeChanged: {
            if(theimage.curScale == defaultScale && theimage.curX == 0 && theimage.curY == 0)
                reset(true, false)
        }

    }

    function performZoom(pos, wheelDelta, zoom_in, zoom_actual, zoom_pinch, zoom_pinchfactor) {

        variables.viewChanged = true

        // adjust for transformOrigin being Center and not TopLeft
        // for some reason (bug?), setting the transformOrigin causes some slight blurriness
        pos.x -= theimage.width/2
        pos.y -= theimage.height/2

        if(wheelDelta != undefined) {
            if(wheelDelta.y > 12)
                wheelDelta.y = 12
            else if(wheelDelta.y < -12)
                wheelDelta.y = -12
        }

        // figure out zoom factor
        var zoomfactor

        // a PINCH occured
        if(zoom_pinch)

            zoomfactor = zoom_pinchfactor

        // zoom to ACTUAL SIZE
        else if(zoom_actual)

            zoomfactor = 1/theimage.curScale

        // zoom IN/OUT
        else {

            if(wheelDelta == undefined) {

                if(zoom_in)
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQSettings.imageviewZoomSpeed*0.01))
                else
                    zoomfactor = 1/Math.max(1.01, Math.min(1.3, 1+PQSettings.imageviewZoomSpeed*0.01))
            } else {

                if(zoom_in)
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(101-PQSettings.imageviewZoomSpeed))))
                else
                    zoomfactor = 1/Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(101-PQSettings.imageviewZoomSpeed))))

            }
        }

        ////////////////////////////////////////////////////////////////////
        // make sure we stay within the specified zoom bounds

        var contW = container.width-2*PQSettings.imageviewMargin
        var contH = container.height-2*PQSettings.imageviewMargin

        if(PQSettings.imageviewZoomMinEnabled) {

            if(theimage.width < contW && theimage.height < contH)
                zoomfactor = Math.max(PQSettings.imageviewZoomMin/(100*theimage.curScale), zoomfactor)
            else
                zoomfactor = Math.max(Math.min(((PQSettings.imageviewZoomMin/100) * contW)/(theimage.width*theimage.curScale), ((PQSettings.imageviewZoomMin/100) * contH)/(theimage.height*theimage.curScale)), zoomfactor)

        }

        if(PQSettings.imageviewZoomMaxEnabled) {

            if(theimage.width < contW && theimage.height < contH)
                zoomfactor = Math.min(PQSettings.imageviewZoomMax/(100*theimage.curScale), zoomfactor)
            else
                zoomfactor = Math.min(PQSettings.imageviewZoomMax/(100*theimage.curScale), zoomfactor)

        }

        ////////////////////////////////////////////////////////////////////

        // update x/y position of image
        var realX = pos.x * theimage.curScale
        var realY = pos.y * theimage.curScale

        // no rotation
        if(theimage.rotateTo%360 == 0) {

            theimage.curX += (1-zoomfactor)*realX
            theimage.curY += (1-zoomfactor)*realY

        // rotated by 90 degrees
        } else if(theimage.rotateTo%360 == 90 || theimage.rotateTo%360 == -270) {

            theimage.curX -= (1-zoomfactor)*realY
            theimage.curY += (1-zoomfactor)*realX

        // rotated by 180 degrees
        } else if(Math.abs(theimage.rotateTo%360) == 180) {

            theimage.curX -= (1-zoomfactor)*realX
            theimage.curY -= (1-zoomfactor)*realY

        // rotated by 270 degrees
        } else if(theimage.rotateTo%360 == 270 || theimage.rotateTo%360 == -90) {

                theimage.curX += (1-zoomfactor)*realY
                theimage.curY -= (1-zoomfactor)*realX

        } else
            console.log("ERROR: unknown rotation step:", theimage.rotateTo)

        // update scale factor
        theimage.curScale *= zoomfactor

    }

    function reset(scaling, position) {

        var sc1 = 1.0
        var sc2 = 1.0

        if(Math.abs(theimage.rotateTo%180) == 90) {
            sc1 = (container.width-2*PQSettings.imageviewMargin)/theimage.height
            sc2 = (container.height-2*PQSettings.imageviewMargin)/theimage.width
        } else {
            sc1 = (container.width-2*PQSettings.imageviewMargin)/theimage.width
            sc2 = (container.height-2*PQSettings.imageviewMargin)/theimage.height
        }

        var useThisScale = 1.0

        if((PQSettings.imageviewFitInWindow && ((Math.abs(theimage.rotateTo%180) == 0 && theimage.width < container.width && theimage.height < container.height) ||
                                                (Math.abs(theimage.rotateTo%180) == 90 && theimage.height < container.width && theimage.width > container.height)))
                ||
                ((Math.abs(theimage.rotateTo%180) != 90 && (theimage.width > container.width || theimage.height > container.height)) ||
                 (Math.abs(theimage.rotateTo%180) == 90 && (theimage.height > container.width || theimage.width > container.height)))) {

            useThisScale = Math.min(sc1, sc2)

        }

        if(position) {
            theimage.curX = 0
            theimage.curY = 0
            if(Math.abs(theimage.rotateTo%180) == 0) {
                cont.x = PQSettings.imageviewMargin + Math.floor(-(theimage.width*(1-sc1))/2)
                cont.y = PQSettings.imageviewMargin + Math.floor(-(theimage.height*(1-sc2))/2)
            }
        }

        if(PQSettings.imageviewAlwaysActualSize)
            useThisScale = 1.0

        if(scaling) {
            defaultScale = useThisScale
            theimage.curScale = useThisScale
            variables.currentZoomLevel = useThisScale*100
            variables.currentPaintedZoomLevel = useThisScale
        }

        if(scaling && position && theimage.rotateTo == 0)
            variables.viewChanged = false

    }

    function storePosRotZoomMirror() {

        variables.zoomRotationMirror[src] = [Qt.point(theimage.curX, theimage.curY), theimage.rotation, theimage.curScale, theimage.mirror, Qt.point(cont.x, cont.y)]

    }

}
