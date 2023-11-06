/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import PQCPopoutGeometry
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: filedialog_window

    //: Window title
    title: qsTranslate("settingsmanager", "Settings Manager")

    geometry: PQCPopoutGeometry.settingsmanagerGeometry
    isMax: PQCPopoutGeometry.settingsmanagerMaximized
    popout: PQCSettings.interfacePopoutSettingsManager
    sizepopout: PQCPopoutGeometry.settingsmanagerForcePopout
    source: "settingsmanager/PQSettingsManager.qml"

    flags: Qt.Window|Qt.WindowStaysOnTopHint
    modality: Qt.ApplicationModal

    minimumWidth: 1000
    minimumHeight: 800

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.settingsmanagerGeometry)
            PQCPopoutGeometry.settingsmanagerGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.settingsmanagerMaximized)
            PQCPopoutGeometry.settingsmanagerMaximized = isMax
    }

}
