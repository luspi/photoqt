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
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: saveas_window

    Component.onCompleted: {
        saveas_window.setX(windowgeometry.fileSaveAsWindowGeometry.x)
        saveas_window.setY(windowgeometry.fileSaveAsWindowGeometry.y)
        saveas_window.setWidth(windowgeometry.fileSaveAsWindowGeometry.width)
        saveas_window.setHeight(windowgeometry.fileSaveAsWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    objectName: "saveaspopout"

    onClosing: {

        windowgeometry.fileSaveAsWindowGeometry = Qt.rect(saveas_window.x, saveas_window.y, saveas_window.width, saveas_window.height)
        windowgeometry.fileSaveAsWindowMaximized = (saveas_window.visibility==Window.Maximized)

        if(variables.visibleItem == "filesaveas")
            variables.visibleItem = ""
    }

    visible: PQSettings.fileSaveAsPopoutElement&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onFileSaveAsPopoutElementChanged: {
            if(!PQSettings.fileSaveAsPopoutElement)
                saveas_window.visible = Qt.binding(function() { return PQSettings.fileSaveAsPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQSaveAs.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return saveas_window.width })
                item.parentHeight = Qt.binding(function() { return saveas_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(saveas_window.objectName)
    }

}
