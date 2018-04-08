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

    title: em.pty+qsTr("Window Mode")
    helptext: em.pty+qsTr("PhotoQt can be used both in fullscreen mode or as a normal window. It was designed with a fullscreen/maximised application in mind, thus it will look best when used that way, but will work just as well any other way.")

    content: [

        CustomCheckBox {
            id: windowmode
            text: em.pty+qsTr("Run PhotoQt in Window Mode")
        },

        CustomCheckBox {
            id: windowmode_deco
            enabled: windowmode.checkedButton
            text: em.pty+qsTr("Show Window Decoration")
        }

    ]

    function setData() {
        windowmode.checkedButton = settings.windowMode
        windowmode_deco.checkedButton = settings.windowDecoration
    }

    function saveData() {
        settings.windowMode = windowmode.checkedButton
        settings.windowDecoration = windowmode_deco.checkedButton
    }

}
