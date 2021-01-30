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

    id: mainmenu_window

    //: Window title
    title: em.pty+qsTranslate("MainMenu", "Main Menu")

    Component.onCompleted: {
        mainmenu_window.x = windowgeometry.mainMenuWindowGeometry.x
        mainmenu_window.y = windowgeometry.mainMenuWindowGeometry.y
        mainmenu_window.width = windowgeometry.mainMenuWindowGeometry.width
        mainmenu_window.height = windowgeometry.mainMenuWindowGeometry.height
    }

    minimumWidth: 100
    minimumHeight: 600

    modality: Qt.NonModal

    objectName: "mainmenupopout"

    onClosing: {
        storeGeometry()
        PQSettings.mainMenuPopoutElement = 0
    }

    Connections {
        target: toplevel
        onClosing: {
            storeGeometry()
        }
    }

    visible: PQSettings.mainMenuPopoutElement
    flags: Qt.WindowStaysOnTopHint

    color: "#88000000"

    Loader {
        source: "PQMainMenu.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return mainmenu_window.width })
                item.parentHeight = Qt.binding(function() { return mainmenu_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(mainmenu_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.mainMenuWindowGeometry = Qt.rect(mainmenu_window.x, mainmenu_window.y, mainmenu_window.width, mainmenu_window.height)
        windowgeometry.mainMenuWindowMaximized = (mainmenu_window.visibility==Window.Maximized)
    }

}
