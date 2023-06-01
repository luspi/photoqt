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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: ele_window

    title: "Popup"

    // THESE ARE REQUIRED

    property rect geometry  // tie to windowgeometry.xxxWindowGeometry
    property bool isMax     // tie to windowgeometry.xxxWindowMaximized
    property string name    // visibleItems string
    property bool popup     // tie to PQSettings.interfacePopoutXxx
    property bool sizepopup // tie to windowsizepopup.xxx
    property string source  // set to source file using qml/ as base

    /////////

    property bool registerQmlAddress: true

    /////////

    Component.onCompleted: {
        ele_window.setX(geometry.x)
        ele_window.setY(geometry.y)
        ele_window.setWidth(geometry.width)
        ele_window.setHeight(geometry.height)
    }

    minimumWidth: 600
    minimumHeight: 400

    modality: Qt.ApplicationModal

    objectName: name+"popout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == name)
            variables.visibleItem = ""
    }

    visible: (sizepopup || popup)&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    color: "#88000000"

    Loader {
        id: curloader
        source: "../"+ele_window.source
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return ele_window.width })
                item.parentHeight = Qt.binding(function() { return ele_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: registerQmlAddress
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(ele_window.objectName)
    }

    function storeGeometry() {
        geometry = Qt.rect(ele_window.x, ele_window.y, ele_window.width, ele_window.height)
        isMax = (ele_window.visibility==Window.Maximized)
    }

    function handleChangesBottomRowWidth(w) {
        ele_window.minimumWidth = Math.max(ele_window.minimumWidth, w)
    }

}
