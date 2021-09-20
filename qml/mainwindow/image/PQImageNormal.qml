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
import "../../elements"

Item {

    id: cont
    x: useStoredData ? variables.zoomRotationMirror[src][4].x : 0
    y: useStoredData ? variables.zoomRotationMirror[src][4].y : 0
    width: container.width
    height: container.height

    property bool imageMoved: false
    property real defaultScale: 1.0
    property bool useStoredData: PQSettings.keepZoomRotationMirror && src in variables.zoomRotationMirror

    // large images can cause flickering when transitioning before scale is reset
    // this makes that invisible
    // this is set to true *after* proper scale has been set
    visible: false

    property bool reloadingImage: false

    Image {

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

        source: "image://full/" + src

        onXChanged:
            imageMoved = true
        onYChanged:
            imageMoved = true

        mirror: useStoredData ? variables.zoomRotationMirror[src][3] : false

        smooth: (!PQSettings.interpolationDisableForSmallImages || width > PQSettings.interpolationThreshold || height > PQSettings.interpolationThreshold)
        mipmap: (scale < defaultScale || (scale < 0.8 && defaultScale < 0.8)) && (!PQSettings.interpolationDisableForSmallImages || width > PQSettings.interpolationThreshold || height > PQSettings.interpolationThreshold)

        Repeater {
            model: defaultScale < 0.8 ? 5 : 0
            delegate: Image {
                id: subimg
                property real threshold: 1.0-index*0.2
                anchors.fill: source == "" ? undefined : theimage
                cache: false
                antialiasing: false
                asynchronous: true
                smooth: theimage.smooth
                mipmap: theimage.scale < defaultScale*threshold
                mirror: theimage.mirror
                source: ""
                sourceSize.width: theimage.width*(defaultScale*threshold)
                sourceSize.height: theimage.height*(defaultScale*threshold)
                visible: (defaultScale < 0.8 || index > 1) && theimage.scale < defaultScale*threshold*1.0001
                onVisibleChanged: {
                    if(visible && source == "" && PQSettings.pixmapCache > 0 && !rotani.running)
                        source = parent.source
                }
                // when the image has changed, we also need to make sure to reload these images
                property string tmpsrc: ""
                Connections {
                    target: cont
                    onReloadingImageChanged: {
                        if(reloadingImage) {
                            tmpsrc = subimg.source
                            subimg.source = ""
                        } else
                            subimg.source = tmpsrc
                    }
                }
            }
        }

        rotation: useStoredData ? variables.zoomRotationMirror[src][1] : 0
        property real rotateTo: 0.0
        onRotateToChanged: {
            rotation = rotateTo
            console.log("reset?", theimage.curScale, defaultScale, imageMoved)
            if(theimage.curScale == defaultScale && !imageMoved) {
                reset(true, false)
            }
        }
        onRotationChanged: {
            if(!rotani.running)
                rotateTo = rotation
            variables.currentRotationAngle = rotation
        }

        property real curScale: useStoredData ? variables.zoomRotationMirror[src][2] : Math.min((container.width-2*PQSettings.marginAroundImage)/theimage.width, (container.height-2*PQSettings.marginAroundImage)/theimage.height)
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
            }
        }

        Behavior on x { NumberAnimation { id: xani; duration: container.justAfterStartup ? 0 : PQSettings.animationDuration*100  } }
        Behavior on y { NumberAnimation { id: yani; duration: container.justAfterStartup ? 0 : PQSettings.animationDuration*100  } }
        Behavior on rotation { NumberAnimation { id: rotani; duration: container.justAfterStartup ? 0 : PQSettings.animationDuration*100  } }
        // its duration it set to proper value after image has been loaded properly (in reset())
        Behavior on scale { NumberAnimation { id: scaleani; duration: PQSettings.animationDuration*100  } }

        Image {
            anchors.fill: parent
            z: -1
            smooth: false
            visible: PQSettings.showTransparencyMarkerBackground
            source: PQSettings.showTransparencyMarkerBackground ? "qrc:/image/checkerboard.png" : ""
            sourceSize.width: Math.max(20, Math.min((parent.height/50), (parent.width/50)))
            fillMode: Image.Tile
        }

        Timer {
            id: theimage_load
            interval: 0
            repeat: false
            running: false
            onTriggered: {
                if(!useStoredData)
                    reset(true, true)
                cont.visible = true
            }
        }

    }

    MouseArea {
        x: -cont.x
        y: -cont.y
        width: container.width
        height: container.height
        hoverEnabled: false
        onPressed: {
            if(PQSettings.closeOnEmptyBackground)
                toplevel.close()
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
            initialScale = theimage.curScale
            contextmenu.hide()
        }

        onPinchUpdated: {

            // disable animations for the pinching
            xani.duration = 0
            yani.duration = 0
            scaleani.duration = 0

            // get the local center position of the pinch
            var localMousePos = theimage.mapFromItem(pincharea, pinch.center)
            // adjust for transformOrigin being Center and not TopLeft
            // for some reason (bug?), setting the transformOrigin causes some slight blurriness
            localMousePos.x -= theimage.width/2
            localMousePos.y -= theimage.height/2

            // the zoomfactor depends on the settings
            var zoomfactor = (initialScale*pinch.scale)/theimage.curScale

            // update x/y position of image
            var realX = localMousePos.x * theimage.curScale
            var realY = localMousePos.y * theimage.curScale

            var newX = theimage.curX + (1-zoomfactor)*realX
            var newY = theimage.curY + (1-zoomfactor)*realY
            theimage.curX = newX
            theimage.curY = newY

            // update scale factor
            theimage.curScale *= zoomfactor

            // re-enable animations after the pinching
            xani.duration = PQSettings.animationDuration*100
            yani.duration = PQSettings.animationDuration*100
            scaleani.duration = PQSettings.animationDuration*100
        }

        MouseArea {
            id: mousearea
            enabled: PQSettings.leftButtonMouseClickAndMove&&!facetagger.visible&&!variables.slideShowActive
            anchors.fill: parent
            drag.target: theimage
            hoverEnabled: false // important, otherwise the mouse pos will not be caught globally!

            onPressAndHold: {
                variables.mousePos = mousearea.mapToItem(bgimage, Qt.point(mouse.x, mouse.y))
                contextmenu.show()
            }

            onClicked:
                contextmenu.hide()

            onReleased: {
                theimage.curX = theimage.x
                theimage.curY = theimage.y
                theimage.x = Qt.binding(function() { return theimage.curX })
                theimage.y = Qt.binding(function() { return theimage.curY })
            }

            Connections {
                target: variables
                onMousePosChanged: {
                    hidecursor.restart()
                    mousearea.cursorShape = Qt.ArrowCursor
                }
                onVisibleItemChanged: {
                    if(variables.visibleItem != "") {
                        hidecursor.stop()
                        mousearea.cursorShape = Qt.ArrowCursor
                    } else {
                        hidecursor.restart()
                        mousearea.cursorShape = Qt.ArrowCursor
                    }
                }
            }

            Timer {
                id: hidecursor
                interval: 1000
                repeat: false
                running: true
                onTriggered:
                    mousearea.cursorShape = Qt.BlankCursor
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
            widthHeightChanged.interval = PQSettings.animationDuration*100
            widthHeightChanged.start()
        }
        onHeightChanged: {
            widthHeightChanged.interval = PQSettings.animationDuration*100
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
                if(!imageMoved && theimage.curScale == defaultScale)
                    reset(true, true)
                else if(!imageMoved)
                    reset(false, true)
            }
        }
    }

    Connections {
        target: container
        onZoomIn: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos
            if(wheelDelta != undefined)
                localMousePos = theimage.mapFromGlobal(variables.mousePos)
            else
                localMousePos = theimage.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))

            // adjust for transformOrigin being Center and not TopLeft
            // for some reason (bug?), setting the transformOrigin causes some slight blurriness
            localMousePos.x -= theimage.width/2
            localMousePos.y -= theimage.height/2

            if(wheelDelta != undefined) {
                if(wheelDelta.y > 12)
                    wheelDelta.y = 12
                else if(wheelDelta.y < -12)
                    wheelDelta.y = -12
            }

            // the zoomfactor depends on the settings
            var zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQSettings.zoomSpeed*0.005))
            if(wheelDelta != undefined)
                zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            // update x/y position of image
            var realX = localMousePos.x * theimage.curScale
            var realY = localMousePos.y * theimage.curScale

            var newX = theimage.curX+(1-zoomfactor)*realX
            var newY = theimage.curY+(1-zoomfactor)*realY
            theimage.curX = newX
            theimage.curY = newY

            // update scale factor
            theimage.curScale *= zoomfactor

        }
        onZoomOut: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos
            if(wheelDelta != undefined)
                localMousePos = theimage.mapFromGlobal(variables.mousePos)
            else
                localMousePos = theimage.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))

            // adjust for transformOrigin being Center and not TopLeft
            // for some reason (bug?), setting the transformOrigin causes some slight blurriness
            localMousePos.x -= theimage.width/2
            localMousePos.y -= theimage.height/2

            if(wheelDelta != undefined) {
                if(wheelDelta.y > 12)
                    wheelDelta.y = 12
                else if(wheelDelta.y < -12)
                    wheelDelta.y = -12
            }

            // the zoomfactor depends on the settings
            var zoomfactor = 1/Math.max(1.01, Math.min(1.3, 1+PQSettings.zoomSpeed*0.01))
            if(wheelDelta != undefined)
                zoomfactor = 1/Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            // update x/y position of image
            var realX = localMousePos.x * theimage.curScale
            var realY = localMousePos.y * theimage.curScale

            var newX = theimage.curX+(1-zoomfactor)*realX
            var newY = theimage.curY+(1-zoomfactor)*realY
            theimage.curX = newX
            theimage.curY = newY

            // update scale factor
            theimage.curScale *= zoomfactor

        }
        onZoomReset: {
            reset(true, true)
        }
        onZoomActual: {

            if(variables.currentZoomLevel == 100)
                return

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos = theimage.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))
            // adjust for transformOrigin being Center and not TopLeft
            // for some reason (bug?), setting the transformOrigin causes some slight blurriness
            localMousePos.x -= theimage.width/2
            localMousePos.y -= theimage.height/2

            // the zoomfactor depends on the settings
            var zoomfactor = 1/theimage.curScale

            // update x/y position of image
            var realX = localMousePos.x * theimage.curScale
            var realY = localMousePos.y * theimage.curScale

            var newX = theimage.curX+(1-zoomfactor)*realX
            var newY = theimage.curY+(1-zoomfactor)*realY
            theimage.curX = newX
            theimage.curY = newY

            // update scale factor
            theimage.curScale *= zoomfactor

        }
        onRotate: {
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
        }
        onMirrorH: {
            var old = theimage.mirror
            theimage.mirror = !old
        }
        onMirrorV: {
            var old = theimage.mirror
            theimage.mirror = !old
            rotani.duration = 0
            theimage.rotateTo += 180
            rotani.duration = PQSettings.animationDuration*100
        }
        onMirrorReset: {
            theimage.mirror = false
        }
    }

    function reset(scaling, position) {

        var sc1 = 1.0
        var sc2 = 1.0

        if(Math.abs(theimage.rotateTo%180) == 90) {
            sc1 = (container.width-2*PQSettings.marginAroundImage)/theimage.height
            sc2 = (container.height-2*PQSettings.marginAroundImage)/theimage.width
        } else {
            sc1 = (container.width-2*PQSettings.marginAroundImage)/theimage.width
            sc2 = (container.height-2*PQSettings.marginAroundImage)/theimage.height
        }

        var useThisScale = 1.0

        if((PQSettings.fitInWindow && ((Math.abs(theimage.rotateTo%180) == 0 && theimage.width < container.width && theimage.height < container.height) ||
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
                cont.x = PQSettings.marginAroundImage + Math.floor(-(theimage.width*(1-sc1))/2)
                cont.y = PQSettings.marginAroundImage + Math.floor(-(theimage.height*(1-sc2))/2)
            }
            imageMoved = false
        }

        if(scaling) {
            defaultScale = useThisScale
            theimage.curScale = useThisScale
            variables.currentZoomLevel = useThisScale*100
            variables.currentPaintedZoomLevel = useThisScale
        }

    }

    function storePosRotZoomMirror() {

        variables.zoomRotationMirror[src] = [Qt.point(theimage.x, theimage.y), theimage.rotation, theimage.curScale, theimage.mirror, Qt.point(cont.x, cont.y)]

    }

}
