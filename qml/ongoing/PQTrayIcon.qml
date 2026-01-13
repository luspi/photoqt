/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import Qt.labs.platform
import PhotoQt

SystemTrayIcon {

    id: trayicon

    visible: PQCSettings.interfaceTrayIcon>0

    icon.source: PQCSettings.interfaceTrayIconMonochrome ? "image://svg/:/other/logo_white.svg" : "image://svg/:/other/logo.svg"

    menu: Menu {
        id: mn

        MenuItem {
            text: (PQCConstants.windowState===Window.Hidden ? qsTranslate("trayicon", "Show PhotoQt") : qsTranslate("trayicon", "Hide PhotoQt"))
            onTriggered:
                trayicon.triggerVisibility()
        }

        MenuItem {
            text: "Quit PhotoQt"
            onTriggered:
                PQCNotify.photoQtQuit()
        }

        Component.onCompleted:
            mn.visible = false

    }

    onActivated: {
        trayicon.triggerVisibility()
    }

    function triggerVisibility() {
        PQCSettings.interfaceTrayIcon = 1
        if(PQCConstants.windowState === Window.Hidden) {
            if(PQCConstants.windowMaxAndNotWindowed)
                PQCNotify.setWindowState(Window.Maximized)
            else
                PQCNotify.setWindowState(Window.Windowed)
        } else if(PQCConstants.windowState === Window.Minimized) {
            PQCNotify.windowRaiseAndFocus()
        } else {
            PQCNotify.setWindowState(Window.Hidden)
        }
    }

}
