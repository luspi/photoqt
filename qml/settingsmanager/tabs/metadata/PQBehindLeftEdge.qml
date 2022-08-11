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
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_metadata", "how to access")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "The meta data can be accessed in two different ways: 1) A floating element that can be moved freely, or 2) hidden behind the left screen edge and shown when the mouse cursor is moved there.")
    content: [

        PQComboBox {
            id: combo
            model: ["floating element", "behind left screen edge"]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataElementBehindLeftEdge = (combo.currentIndex==1)
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        combo.currentIndex = (PQSettings.metadataElementBehindLeftEdge ? 1 : 0)
    }

}
