/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

    id: settingsmanager_window

    //: Window title
    title: em.pty+qsTranslate("settingsmanager", "Settings Manager")

    Component.onCompleted: {
        settingsmanager_window.setX(windowgeometry.settingsManagerWindowGeometry.x)
        settingsmanager_window.setY(windowgeometry.settingsManagerWindowGeometry.y)
        settingsmanager_window.setWidth(windowgeometry.settingsManagerWindowGeometry.width)
        settingsmanager_window.setHeight(windowgeometry.settingsManagerWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    objectName: "settingsmanagerpopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "settingsmanager")
            variables.visibleItem = ""
    }

    visible: (windowsizepopup.settingsManager || PQSettings.interfacePopoutSettingsManager)&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onInterfacePopoutSettingsManagerChanged: {
            if(!PQSettings.interfacePopoutSettingsManager)
                settingsmanager_window.visible = Qt.binding(function() { return (windowsizepopup.settingsManager||PQSettings.interfacePopoutSettingsManager)&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQSettingsManager.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return settingsmanager_window.width })
                item.parentHeight = Qt.binding(function() { return settingsmanager_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(settingsmanager_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.settingsManagerWindowGeometry = Qt.rect(settingsmanager_window.x, settingsmanager_window.y, settingsmanager_window.width, settingsmanager_window.height)
        windowgeometry.settingsManagerWindowMaximized = (settingsmanager_window.visibility==Window.Maximized)
    }

}
