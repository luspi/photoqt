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

import QtQuick
import PQCFileFolderModel
import PhotoQt

Item {

    id: mastertouch_top

    width: PQCConstants.windowWidth // qmllint disable unqualified
    height: PQCConstants.windowHeight // qmllint disable unqualified

    visible: PQCFileFolderModel.countMainView>0 // qmllint disable unqualified

    MultiPointTouchArea {

        id: lefttouch

        y: (parent.height-height)/2
        width: Math.min(150, mastertouch_top.width/5)
        height: 200
        mouseEnabled: false

        enabled: PQCSettings.interfaceEdgeLeftAction!==""

        maximumTouchPoints: 1

        property point initPoint: Qt.point(-1,-1)

        property bool cmdTriggered: false

        onPressed: (points) => {
            PQCConstants.touchGestureActive = true
            initPoint.x = points[0].x
            initPoint.y = points[0].y
        }

        onUpdated: (points) => {

            if(cmdTriggered) return

            if(points[0].x-initPoint.x > 50) {

                cmdTriggered = true
                mastertouch_top.handleEdge("lefttoright")

            }

        }

        onReleased: {
            cmdTriggered = false
            PQCConstants.touchGestureActive = false
        }

    }

    MultiPointTouchArea {

        id: righttouch

        x: (parent.width-width)
        y: (parent.height-height)/2
        width: Math.min(150, mastertouch_top.width/5)
        height: 200
        mouseEnabled: false

        enabled: PQCSettings.interfaceEdgeRightAction!==""

        maximumTouchPoints: 1

        property point initPoint: Qt.point(-1,-1)

        property bool cmdTriggered: false

        onPressed: (points) => {
            PQCConstants.touchGestureActive = true
            initPoint.x = points[0].x
            initPoint.y = points[0].y
        }

        onUpdated: (points) => {

            if(cmdTriggered) return

            if(initPoint.x-points[0].x > 50) {

                cmdTriggered = true
                mastertouch_top.handleEdge("righttoleft")

            }

        }

        onReleased: {
            cmdTriggered = false
            PQCConstants.touchGestureActive = false
        }

    }

    MultiPointTouchArea {

        id: toptouch

        x: (parent.width-width)/2
        width: 200
        height: Math.min(100, mastertouch_top.height/5)
        mouseEnabled: false

        enabled: PQCSettings.interfaceEdgeTopAction!==""

        maximumTouchPoints: 1

        property point initPoint: Qt.point(-1,-1)

        property bool cmdTriggered: false

        onPressed: (points) => {
            PQCConstants.touchGestureActive = true
            initPoint.x = points[0].x
            initPoint.y = points[0].y
        }

        onUpdated: (points) => {

            if(cmdTriggered) return

            if(points[0].y-initPoint.y > 50) {

                cmdTriggered = true
                mastertouch_top.handleEdge("toptobottom")

            }

        }

        onReleased: {
            cmdTriggered = false
            PQCConstants.touchGestureActive = false
        }

    }

    MultiPointTouchArea {

        id: bottomtouch

        x: (parent.width-width)/2
        y: (parent.height-height)
        width: 200
        height: Math.min(100, mastertouch_top.height/5)
        mouseEnabled: false

        enabled: PQCSettings.interfaceEdgeBottomAction!==""

        maximumTouchPoints: 1

        property point initPoint: Qt.point(-1,-1)

        property bool cmdTriggered: false

        onPressed: (points) => {
            PQCConstants.touchGestureActive = true
            initPoint.x = points[0].x
            initPoint.y = points[0].y
        }

        onUpdated: (points) => {

            if(cmdTriggered) return

            if(initPoint.y-points[0].y > 50) {

                cmdTriggered = true
                mastertouch_top.handleEdge("bottomtotop")

            }

        }

        onReleased: {
            cmdTriggered = false
            PQCConstants.touchGestureActive = false
        }

    }

    function handleEdge(direction : string) {

        // swipe from left to right
        if(direction === "lefttoright") {

            if(checkVisibility(PQCSettings.interfaceEdgeRightAction)) {
                hideElement(PQCSettings.interfaceEdgeRightAction)
            } else if(!checkVisibility(PQCSettings.interfaceEdgeLeftAction)) {
                showElement(PQCSettings.interfaceEdgeLeftAction)
            }

        // swipe from right to left
        } else if(direction === "righttoleft") {

            if(checkVisibility(PQCSettings.interfaceEdgeLeftAction)) {
                hideElement(PQCSettings.interfaceEdgeLeftAction)
            } else if(!checkVisibility(PQCSettings.interfaceEdgeRightAction)) {
                showElement(PQCSettings.interfaceEdgeRightAction)
            }

        } else if(direction === "toptobottom") {

            if(checkVisibility(PQCSettings.interfaceEdgeBottomAction)) {
                hideElement(PQCSettings.interfaceEdgeBottomAction)
            } else if(!checkVisibility(PQCSettings.interfaceEdgeTopAction)) {
                showElement(PQCSettings.interfaceEdgeTopAction)
            }

        } else if(direction === "bottomtotop") {

            if(checkVisibility(PQCSettings.interfaceEdgeTopAction)) {
                hideElement(PQCSettings.interfaceEdgeTopAction)
            } else if(!checkVisibility(PQCSettings.interfaceEdgeBottomAction)) {
                showElement(PQCSettings.interfaceEdgeBottomAction)
            }

        }

    }

    function checkVisibility(item : string) : bool {

        console.log("args: item =", item)

        if(item === "metadata")
            return PQCConstants.metadataOpacity > 0
        if(item === "mainmenu")
            return PQCConstants.mainmenuOpacity > 0
        if(item === "thumbnails")
            return PQCConstants.thumbnailsBarOpacity > 0

        return false

    }

    function hideElement(item : string) {
        if(item === "") return
        PQCNotify.loaderPassOn("forcehide", [item])
    }

    function showElement(item : string) {
        if(item === "") return
        PQCNotify.loaderPassOn("forceshow", [item])
    }

}
