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

import QtQuick
import QtQuick.Window

Window {

    id: ele_window

    title: "Popout"

    // THESE ARE REQUIRED

    property rect geometry  // tie to PQCPopoutGeometry.xxxGeometry
    property bool isMax     // tie to PQCPopoutGeometry.xxxMaximized
    property bool popout    // tie to PQSettings.interfacePopoutXxx
    property bool sizepopout// tie to PQCPopoutGeometry.xxxForcePopout
    property string source  // set to source file using qml/ as base

    /////////

    signal popoutClosed()

    /////////

    Component.onCompleted: {
        if(isMax) {
            showMaximized()
        }
        ele_window.setX(geometry.x)
        ele_window.setY(geometry.y)
        ele_window.setWidth(geometry.width)
        ele_window.setHeight(geometry.height)
    }

    minimumWidth: 600
    minimumHeight: 400

    modality: Qt.ApplicationModal

    onClosing: {
        popoutClosed()
    }

    visible: (sizepopout || popout)&&curloader.item.opacity===1
    flags: Qt.WindowStaysOnTopHint

    color: PQCLook.transColor

    onXChanged:
        updateGeometry.restart()
    onYChanged:
        updateGeometry.restart()
    onWidthChanged:
        updateGeometry.restart()
    onHeightChanged:
        updateGeometry.restart()
    onVisibilityChanged:
        updateMaxStatus.restart()

    Loader {
        id: curloader
        source: "../"+ele_window.source
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return ele_window.width })
                item.parentHeight = Qt.binding(function() { return ele_window.height })
            }
    }

    Timer {
        id: updateGeometry
        interval: 200
        repeat: false
        onTriggered: {
            if(ele_window.visibility !== Window.Maximized)
                ele_window.geometry = Qt.rect(ele_window.x, ele_window.y, ele_window.width, ele_window.height)
        }
    }

    Timer {
        id: updateMaxStatus
        interval: 200
        repeat: false
        onTriggered:
            ele_window.isMax = (ele_window.visibility==Window.Maximized)
    }

    function handleChangesBottomRowWidth(w) {
        ele_window.minimumWidth = Math.max(ele_window.minimumWidth, w)
    }

}
