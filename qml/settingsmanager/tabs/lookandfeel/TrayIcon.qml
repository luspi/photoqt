/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

Entry {

    title: em.pty+qsTr("Hide to Tray Icon")
    helptext: em.pty+qsTr("PhotoQt can make use of a tray icon in the system tray. It can also hide to the system tray when closing it instead\
 of quitting. It is also possible to start PhotoQt already minimised to the tray (e.g. at system startup) when called with \"--start-in-tray\".")


    ExclusiveGroup { id: tray; }

    content: [

        CustomRadioButton {
            id: tray_one
            //: The tray icon is the icon in the system tray
            text: em.pty+qsTr("No tray icon")
            exclusiveGroup: tray
            checked: true
        },

        CustomRadioButton {
            id: tray_two
            //: The tray icon is the icon in the system tray
            text: em.pty+qsTr("Hide to tray icon")
            exclusiveGroup: tray
        },

        CustomRadioButton {
            id: tray_three
            //: The tray icon is the icon in the system tray
            text: em.pty+qsTr("Show tray icon, but don't hide to it")
            exclusiveGroup: tray
        }

    ]

    function setData() {
        if(settings.trayIcon === 0)
            tray_one.checked = true
        else if(settings.trayIcon === 1)
            tray_two.checked = true
        else if(settings.trayIcon === 2)
            tray_three.checked = true
    }

    function saveData() {
        if(tray_one.checked)
            settings.trayIcon = 0
        else if(tray_two.checked)
            settings.trayIcon = 1
        else if(tray_three.checked)
            settings.trayIcon = 2
    }

}
