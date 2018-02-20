/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import "../shortcuts/mouseshortcuts.js" as AnalyseMouse
import "../handlestuff.js" as Handle

PinchArea {

    id: pincharea

    anchors.fill: parent

    pinch.target: imageitem.currentImage1
    pinch.minimumRotation: -360
    pinch.maximumRotation: 360
    pinch.minimumScale: 0.1
    pinch.maximumScale: 10
    pinch.dragAxis: Pinch.XAndYAxis

    Connections {
        target: imageitem
        onCurrentIdChanged: {
            if(getanddostuff.convertIdIntoString(imageitem.currentId) === "image1")
                pincharea.pinch.target = imageitem.currentImage1
            else if(getanddostuff.convertIdIntoString(imageitem.currentId) === "image2")
                pincharea.pinch.target = imageitem.currentImage2
            else if(getanddostuff.convertIdIntoString(imageitem.currentId) === "imageANIM1")
                pincharea.pinch.target = imageitem.currentImageANIM1
            else if(getanddostuff.convertIdIntoString(imageitem.currentId) === "imageANIM2")
                pincharea.pinch.target = imageitem.currentImageANIM2
            else
                console.error("MainView / HandleMouseMovements", "ERROR: Invalid image id:", imageitem.currentId)
        }
    }

    MouseArea {

        id: mousearea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

        drag.target: (dragSource!==Qt.MouseEventNotSynthesized||(settings.leftButtonMouseClickAndMove&&!variables.imageItemBlocked&&buttonID==Qt.LeftButton)) ? imageitem.returnImageContainer() : undefined

        property point pressedPosStart: Qt.point(-1,-1)
        property point pressedPosEnd: Qt.point(-1,-1)

        property int buttonID: Qt.LeftButton
        property int dragSource: Qt.MouseEventNotSynthesized

        onPositionChanged:
            handleMousePositionChange(mouse.x, mouse.y)
        onPressed: {
            buttonID = mouse.button
            // the mouse.source property is only available starting at Qt 5.7
            if(mouse.source != undefined)
                dragSource = mouse.source
            pressedPosStart = Qt.point(mouse.x, mouse.y)
            variables.shorcutsMouseGesturePointIntermediate = Qt.point(-1,-1)
        }
        onReleased: {
            pressedPosEnd = Qt.point(mouse.x, mouse.y)
            shortcuts.analyseMouseEvent(pressedPosStart, mouse)
            Handle.checkIfClickOnEmptyArea(pressedPosStart, pressedPosEnd)
            pressedPosStart = Qt.point(-1,-1)
        }

        onWheel: shortcuts.analyseWheelEvent(wheel)

        function handleMousePositionChange(xPos, yPos) {

            if(pressedPosStart.x !== -1 || pressedPosStart.y !== -1) {
                var before = variables.shorcutsMouseGesturePointIntermediate
                if(variables.shorcutsMouseGesturePointIntermediate.x === -1 || variables.shorcutsMouseGesturePointIntermediate.y === -1)
                    before = pressedPosStart
                AnalyseMouse.analyseMouseGestureUpdate(xPos, yPos, before)
            }

            var w = Math.max(1, Math.min(20, settings.hotEdgeWidth))*5

            if(xPos > mainwindow.width-w && !variables.slideshowRunning)
                mainmenu.show()
            else
                mainmenu.hide()

            if(xPos < w && !variables.slideshowRunning && settings.metadataEnableHotEdge) {
                if((variables.filter != "" && yPos > quickinfo.x+quickinfo.height+25) || variables.filter == "")
                    metadata.show()
            } else
                metadata.hide()

            if(settings.thumbnailPosition!="Top") {
                if(yPos > mainwindow.height-w && !variables.slideshowRunning && !settings.thumbnailDisable)
                    call.show("thumbnails")
                else if((!settings.thumbnailKeepVisible && !settings.thumbnailKeepVisibleWhenNotZoomedIn) || (settings.thumbnailKeepVisibleWhenNotZoomedIn && imageitem.isZoomedIn()))
                    call.hide("thumbnails")
            } else {
                if(yPos < w && !variables.slideshowRunning && !settings.thumbnailDisable)
                    call.show("thumbnails")
                else if((!settings.thumbnailKeepVisible && !settings.thumbnailKeepVisibleWhenNotZoomedIn) || (settings.thumbnailKeepVisibleWhenNotZoomedIn && imageitem.isZoomedIn()))
                    call.hide("thumbnails")
            }

            if(yPos < w)
                call.show("slideshowbar")
            else
                call.hide("slideshowbar")

        }

    }

}
