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

    id: mapexplorer_window

    //: Window title
    title: em.pty+qsTranslate("mapexplorer", "Map Epxlorer")

    minimumWidth: 800
    minimumHeight: 600

    modality: (PQSettings.interfacePopoutMapExplorer||windowsizepopup.mapExplorer) ? Qt.NonModal : Qt.ApplicationModal
    flags: Qt.WindowStaysOnTopHint

    color: "#88000000"

    objectName: "mapexplorerpopout"

    Loader {
        source: "PQMapExplorer.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return mapexplorer_window.width })
                item.parentHeight = Qt.binding(function() { return mapexplorer_window.height })
            }
    }

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "mapexplorer")
            variables.visibleItem = ""
    }

    Component.onCompleted:  {

        if(windowgeometry.mapExplorerWindowMaximized)

            mapexplorer_window.visibility = Window.Maximized

        else {

            mapexplorer_window.setX(windowgeometry.mapExplorerWindowGeometry.x)
            mapexplorer_window.setY(windowgeometry.mapExplorerWindowGeometry.y)
            mapexplorer_window.setWidth(windowgeometry.mapExplorerWindowGeometry.width)
            mapexplorer_window.setHeight(windowgeometry.mapExplorerWindowGeometry.height)

        }

    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(mapexplorer_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.mapExplorerWindowMaximized = (mapexplorer_window.visibility==Window.Maximized)
        windowgeometry.mapExplorerWindowGeometry = Qt.rect(mapexplorer_window.x, mapexplorer_window.y, mapexplorer_window.width, mapexplorer_window.height)
    }

}
