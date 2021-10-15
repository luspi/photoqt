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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_interface", "empty area around image")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "How to handle clicks on empty area around images.")
    content: [
        Flow {
            spacing: 10
            width: set.contwidth
            PQRadioButton {
                id: closecheck
                //: Used as in: Close PhotoQt on click on empty area around main image
                text: em.pty+qsTranslate("settingsmanager_interface", "close on click")
                tooltip: em.pty+qsTranslate("settingsmanager_interface", "Close PhotoQt when click occurred on empty area around image")
            }
            PQRadioButton {
                id: navcheck
                //: Used as in: Close PhotoQt on click on empty area around main image
                text: em.pty+qsTranslate("settingsmanager_interface", "navigate on click")
                tooltip:em.pty+qsTranslate("settingsmanager_interface",  "Go to next/previous image if click occurred in left/right half of window")
            }
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            closecheck.checked = PQSettings.closeOnEmptyBackground
            navcheck.checked = PQSettings.navigateOnEmptyBackground
        }

        onSaveAllSettings: {
            PQSettings.closeOnEmptyBackground = closecheck.checked
            PQSettings.navigateOnEmptyBackground = navcheck.checked
        }

    }

}
