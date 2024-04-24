/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCWindowGeometry
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: settingsmanager_window

    //: Window title
    title: qsTranslate("settingsmanager", "Settings Manager") + " | PhotoQt"

    geometry: PQCWindowGeometry.settingsmanagerGeometry
    isMax: PQCWindowGeometry.settingsmanagerMaximized
    popout: PQCSettings.interfacePopoutSettingsManager
    sizepopout: PQCWindowGeometry.settingsmanagerForcePopout
    source: "settingsmanager/PQSettingsManager.qml"

    minimumWidth: 1000
    minimumHeight: 800

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.settingsmanagerGeometry)
            PQCWindowGeometry.settingsmanagerGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.settingsmanagerMaximized)
            PQCWindowGeometry.settingsmanagerMaximized = isMax
    }

}
