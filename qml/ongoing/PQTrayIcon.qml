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
import Qt.labs.platform

import "../"

SystemTrayIcon {

    id: trayicon

    visible: PQCSettings.interfaceTrayIcon>0 // qmllint disable unqualified

    icon.source: PQCSettings.interfaceTrayIconMonochrome ? "image://svg/:/other/logo_white.svg" : "image://svg/:/other/logo.svg" // qmllint disable unqualified

    property PQMainWindow acces_toplevel: toplevel // qmllint disable unqualified

    menu: Menu {
        id: mn

        MenuItem {
            text: (trayicon.acces_toplevel.visible ? "Hide PhotoQt" : "Show PhotoQt")
            onTriggered: {
                PQCSettings.interfaceTrayIcon = 1 // qmllint disable unqualified
                trayicon.acces_toplevel.visible = !trayicon.acces_toplevel.visible
                if(trayicon.acces_toplevel.visible) {
                    if(trayicon.acces_toplevel.visibility === Window.Minimized)
                        trayicon.acces_toplevel.visibility = (toplevel.maxAndNowWindowed ? Window.Maximized : Window.Windowed)
                    trayicon.acces_toplevel.raise()
                    trayicon.acces_toplevel.requestActivate()
                }
            }
        }

        MenuItem {
            text: "Quit PhotoQt"
            onTriggered:
                trayicon.acces_toplevel.quitPhotoQt()
        }

        Component.onCompleted:
            mn.visible = false

    }

    onActivated: {
        PQCSettings.interfaceTrayIcon = 1 // qmllint disable unqualified
        trayicon.acces_toplevel.visible = !trayicon.acces_toplevel.visible
        if(trayicon.acces_toplevel.visible) {
            if(trayicon.acces_toplevel.visibility === Window.Minimized)
                trayicon.acces_toplevel.visibility = (toplevel.maxAndNowWindowed ? Window.Maximized : Window.Windowed)
            trayicon.acces_toplevel.raise()
            trayicon.acces_toplevel.requestActivate()
        }
    }

}
