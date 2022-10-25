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
import Qt.labs.platform 1.0
import "elements"

SystemTrayIcon {

    id: trayicon
    visible: PQSettings.interfaceTrayIcon>0

    iconSource: "/other/icon.png"

    menu: PQMenu {
        id: mn

        entries: [(toplevel.visible ? "Hide PhotoQt" : "Show PhotoQt"),
                  "Quit PhotoQt"]

        onTriggered: {
            if(index == 0) {
                PQSettings.interfaceTrayIcon = 1
                toplevel.visible = !toplevel.visible
                if(toplevel.visible) {
                    if(toplevel.visibility == Window.Minimized)
                        toplevel.visibility = Window.Maximized
                    toplevel.raise()
                    toplevel.requestActivate()
                }
            } else if(index == 1)
                toplevel.quitPhotoQt()
        }

    }

    onActivated: {
        PQSettings.interfaceTrayIcon = 1
        toplevel.visible = !toplevel.visible
        if(toplevel.visible) {
            if(toplevel.visibility == Window.Minimized)
                toplevel.visibility = Window.Maximized
            toplevel.raise()
            toplevel.requestActivate()
        }
    }

}
