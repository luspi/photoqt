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

    AnimatedImage {

        id: theimage
        x: useStoredData ? variables.zoomRotationMirror[src][0].x : 0
        y: useStoredData ? variables.zoomRotationMirror[src][0].y : 0
        width: sourceSize.width
        height: sourceSize.height
        fillMode: Image.Pad
        asynchronous: true
        clip: true

        source: "file:/" + src

        onXChanged:
            imageMoved = true
        onYChanged:
            imageMoved = true

        mirror: useStoredData ? variables.zoomRotationMirror[src][3] : false

        smooth: (!PQSettings.interpolationDisableForSmallImages || width > PQSettings.interpolationThreshold || height > PQSettings.interpolationThreshold)
        mipmap: (scale < defaultScale || (scale < 0.8 && defaultScale < 0.8)) && (!PQSettings.interpolationDisableForSmallImages || width > PQSettings.interpolationThreshold || height > PQSettings.interpolationThreshold)

        rotation: useStoredData ? variables.zoomRotationMirror[src][1] : 0
        property real rotateTo: 0.0
        onRotateToChanged: {
            rotation = rotateTo
            if(theimage.scale == defaultScale && !imageMoved)
                reset(true, false)
        }
        onRotationChanged: {
            if(!rotani.running)
                rotateTo = rotation
            variables.currentRotationAngle = rotation
        }

        scale: useStoredData ? variables.zoomRotationMirror[src][2] : 1
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
        Behavior on scale { NumberAnimation { id: scaleani; duration: 0  } }

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

        pinch.target: theimage
        pinch.minimumRotation: -360*5
        pinch.maximumRotation: 360*5
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis

        onPinchStarted:
            contextmenu.hide()

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
                if(!imageMoved && theimage.scale == defaultScale)
                    reset(true, true)
                else if(!imageMoved)
                    reset(false, true)
            }
        }
    }

    Connections {
        target: variables
        property bool pauseStateWhenElementOpens: false
        onVisibleItemChanged: {
            if(variables.visibleItem == "")
                theimage.paused = pauseStateWhenElementOpens
            else {
                pauseStateWhenElementOpens = theimage.paused
                theimage.paused = true
            }
        }
    }

    Connections {
        target: container
        onZoomIn: {
            theimage.scale *= (1+PQSettings.zoomSpeed/100)
        }
        onZoomOut: {
            theimage.scale /= (1+PQSettings.zoomSpeed/100)
        }
        onZoomReset: {
            reset(true, true)
        }
        onZoomActual: {
            if(variables.currentZoomLevel != 100)
                theimage.scale = 1
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
        onJustAfterStartupChanged: {
            scaleani.duration = PQSettings.animationDuration*100
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
            theimage.x = 0
            theimage.y = 0
            if(Math.abs(theimage.rotateTo%180) == 0) {
                cont.x = PQSettings.marginAroundImage + Math.floor(-(theimage.width*(1-sc1))/2)
                cont.y = PQSettings.marginAroundImage + Math.floor(-(theimage.height*(1-sc2))/2)
            }
            imageMoved = false
        }

        if(scaling) {
            defaultScale = useThisScale
            theimage.scale = useThisScale
            variables.currentZoomLevel = useThisScale*100
            variables.currentPaintedZoomLevel = useThisScale
        }

        // set the right duration
        // at start this value is zero (to load image without animation) and needs to be set here
        if(!container.justAfterStartup)
            scaleani.duration = PQSettings.animationDuration*100

    }

    function storePosRotZoomMirror() {

        variables.zoomRotationMirror[src] = [Qt.point(theimage.x, theimage.y), theimage.rotation, theimage.scale, theimage.mirror, Qt.point(cont.x, cont.y)]

    }

}
