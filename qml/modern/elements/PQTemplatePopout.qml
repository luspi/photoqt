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
import QtQuick.Window
import PhotoQt

Window {

    id: ele_window

    title: "Popout"

    // THESE ARE REQUIRED

    property rect geometry  // tie to PQCWindowGeometry.xxxGeometry
    property rect originalGeometry  // tie to PQCWindowGeometry.xxxGeometry
    property bool isMax     // tie to PQCWindowGeometry.xxxMaximized
    property bool popout    // tie to PQSettings.interfacePopoutXxx
    property bool sizepopout// tie to PQCWindowGeometry.xxxForcePopout
    property string source  // set to source file using qml/ as base

    /////////

    signal popoutOpened()
    signal popoutClosed()

    /////////

    property alias loaderitem: curloader.item

    /////////

    Component.onCompleted: {
        ele_window.setX(geometry.x)
        ele_window.setY(geometry.y)
        if(makeWindowNotResizable) {
            minimumHeight = height
            minimumWidth = width
            maximumHeight = height
            maximumWidth = width
        } else {
            ele_window.setWidth(geometry.width)
            ele_window.setHeight(geometry.height)
        }
    }

    onClosing:
        ele_window.popoutClosed()

    minimumWidth: 600
    minimumHeight: 400

    modality: Qt.ApplicationModal

    onVisibleChanged: {
        if(visible) {
            popoutOpened()
        } else {
            popoutClosed()
        }
    }

    property bool makeWindowNotResizable: false

    visible: false
    flags: Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint

    color: PQCLook.transColor 

    onXChanged:
        updateGeometry.restart()
    onYChanged:
        updateGeometry.restart()
    onWidthChanged: {
        updateGeometry.restart()
        if(makeWindowNotResizable) {
            minimumWidth = width
            maximumWidth = width
        }
    }
    onHeightChanged: {
        updateGeometry.restart()
        if(makeWindowNotResizable) {
            minimumHeight = height
            maximumHeight = height
        }
    }
    onVisibilityChanged:
        updateMaxStatus.restart()

    Loader {
        id: curloader
        source: "../"+ele_window.source
        onStatusChanged:
            if(status == Loader.Ready) {
                item.popoutWindowUsed = true
                item.parentWidth = Qt.binding(function() { return ele_window.width })
                item.parentHeight = Qt.binding(function() { return ele_window.height })
                if(ele_window.popout)
                    ele_window.visible = true
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

    function handleChangesBottomRowWidth(w : int) {
        ele_window.minimumWidth = Math.max(ele_window.minimumWidth, w)
    }

}
