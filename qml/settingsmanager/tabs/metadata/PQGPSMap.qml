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
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_metadata", "GPS online map")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "Which map service to use when a GPS position is clicked.")
    content: [

        PQComboBox {
            id: gps_combo
            model: ["openstreetmap.org", "maps.google.com", "bing.com/maps"]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataGpsMap = gps_combo.currentText
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        for(var i = 0; i < gps_combo.count; ++i)
            if(gps_combo.model[i] == PQSettings.metadataGpsMap)
                gps_combo.currentIndex = i
    }

}
