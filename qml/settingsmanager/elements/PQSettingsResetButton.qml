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
import PhotoQt

Item {

    id: resetbutton

    width: parent.width
    // a value of 1 is important to reduce the empty spacing added below and above the reset button
    height: 1

    signal resetToDefaults()

    PQButtonIcon {
        id: btn
        x: resetbutton.width - width - 10
        width: 20
        height: 20
        opacity: hovered ? 1 : 0.5
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
        tooltip: qsTranslate("settingsmanager", "reset to default values")
        onClicked: (pos) => {
            resetbutton.resetToDefaults()
        }
    }

}
