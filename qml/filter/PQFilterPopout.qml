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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: filter_window

    //: Window title
    title: em.pty+qsTranslate("filter", "Filter")

    Component.onCompleted: {
        filter_window.setX(windowgeometry.filterWindowGeometry.x)
        filter_window.setY(windowgeometry.filterWindowGeometry.y)
        filter_window.setWidth(windowgeometry.filterWindowGeometry.width)
        filter_window.setHeight(windowgeometry.filterWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    objectName: "filterpopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "filter")
            variables.visibleItem = ""
    }

    visible: PQSettings.interfacePopoutFilter&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onInterfacePopoutFilterChanged: {
            if(!PQSettings.interfacePopoutFilter)
                filter_window.visible = Qt.binding(function() { return PQSettings.interfacePopoutFilter&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQFilter.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return filter_window.width })
                item.parentHeight = Qt.binding(function() { return filter_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(filter_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.filterWindowGeometry = Qt.rect(filter_window.x, filter_window.y, filter_window.width, filter_window.height)
        windowgeometry.filterWindowMaximized = (filter_window.visibility==Window.Maximized)
    }

}
