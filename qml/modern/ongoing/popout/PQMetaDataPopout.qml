/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import "../../elements"

PQTemplatePopout {

    id: metadata_popout

    //: Window title
    title: qsTranslate("actions", "Metadata") + " | PhotoQt"

    geometry: PQCWindowGeometry.metadataGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.metadataMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutMetadata // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.metadataForcePopout // qmllint disable unqualified
    source: "ongoing/PQMetaData.qml"

    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 300

    onPopoutClosed: {
        PQCSettings.interfacePopoutMetadata = false // qmllint disable unqualified
        close()
        PQCNotify.executeInternalCommand("__showMetaData")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMetadata) // qmllint disable unqualified
            PQCSettings.interfacePopoutMetadata = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.metadataGeometry) // qmllint disable unqualified
            PQCWindowGeometry.metadataGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.metadataMaximized) // qmllint disable unqualified
            PQCWindowGeometry.metadataMaximized = isMax
    }

}
