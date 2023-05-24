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

    id: mapcurrent_window

    //: Window title
    title: em.pty+qsTranslate("histogram", "Map (Current Image)")

    Component.onCompleted: {
        mapcurrent_window.x = windowgeometry.mapCurrentWindowGeometry.x
        mapcurrent_window.y = windowgeometry.mapCurrentWindowGeometry.y
        mapcurrent_window.width = windowgeometry.mapCurrentWindowGeometry.width
        mapcurrent_window.height = windowgeometry.mapCurrentWindowGeometry.height
    }

    minimumWidth: 100
    minimumHeight: 100

    modality: Qt.NonModal

    objectName: "mapcurrentpopout"

    onClosing: {
        storeGeometry()
        PQSettings.mapviewCurrentVisible = 0
    }

    Connections {
        target: toplevel
        onClosing: {
            storeGeometry()
        }
    }

    visible: (PQSettings.interfacePopoutMapCurrent&&PQSettings.mapviewCurrentVisible)
    flags: Qt.WindowStaysOnTopHint

    color: "#88000000"

    Loader {
        source: "PQMapCurrent.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return mapcurrent_window.width })
                item.parentHeight = Qt.binding(function() { return mapcurrent_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(mapcurrent_window.objectName)
    }

    Connections {
        target: PQSettings
        onInterfacePopoutMapCurrentChanged: {
            if(!PQSettings.interfacePopoutMapCurrent)
                mapcurrent_window.visible = Qt.binding(function() { return PQSettings.interfacePopoutMapCurrent&&PQSettings.mapviewCurrentVisible; })
        }
    }

    function storeGeometry() {
        windowgeometry.mapCurrentWindowGeometry = Qt.rect(mapcurrent_window.x, mapcurrent_window.y, mapcurrent_window.width, mapcurrent_window.height)
        windowgeometry.mapCurrentWindowMaximized = (mapcurrent_window.visibility==Window.Maximized)
    }

}
