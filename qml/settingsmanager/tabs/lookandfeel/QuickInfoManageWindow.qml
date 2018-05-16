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

import "../../../elements"
import "../../"

Entry {

    title: em.pty+qsTr("Basic window management")
    helptext: em.pty+qsTr("It is possible to use the label with the quick infos (filename, etc.) for some basic window management.\
 You can click and drag to move the window around, and a double click toggles whether the windows is maximized or not.") + "<br><br>" +
              em.pty+qsTr("Note: This is only possible when the window is not in fullscreen!")

    content: [

        CustomCheckBox {
            id: managewindow
            text: em.pty+qsTr("Enable basic window management")
        }

    ]

    function setData() {
        managewindow.checkedButton = settings.quickInfoManageWindow
    }

    function saveData() {
        settings.quickInfoManageWindow = managewindow.checkedButton
    }

}
