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

    id: mainmenu_window

    //: Window title
    title: qsTranslate("actions", "Metadata")

    geometry: PQCPopoutGeometry.metadataGeometry
    isMax: PQCPopoutGeometry.metadataMaximized
    popout: PQCSettings.interfacePopoutMetadata
    sizepopout: PQCPopoutGeometry.metadataForcePopout
    source: "ongoing/PQMetaData.qml"

    flags: Qt.Window|Qt.WindowStaysOnTopHint
    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 600

    onPopoutClosed: {
        PQCSettings.interfacePopoutMetadata = false
        close()
        PQCNotify.executeInternalCommand("__showMetaData")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMetadata)
            PQCSettings.interfacePopoutMetadata = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.metadataGeometry)
            PQCPopoutGeometry.metadataGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.metadataMaximized)
            PQCPopoutGeometry.metadataMaximized = isMax
    }

}
