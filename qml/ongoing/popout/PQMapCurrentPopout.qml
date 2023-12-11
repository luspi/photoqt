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
import PQCWindowGeometry
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: mapcurrent_popout

    //: Window title
    title: qsTranslate("mapcurrent", "Current location")

    geometry: PQCWindowGeometry.mapcurrentGeometry
    isMax: PQCWindowGeometry.mapcurrentMaximized
    popout: PQCSettings.interfacePopoutMapCurrent
    sizepopout: PQCWindowGeometry.mapcurrentForcePopout
    source: "ongoing/PQMapCurrent.qml"

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        PQCSettings.interfacePopoutMapCurrent = false
        close()
        PQCNotify.executeInternalCommand("__showMapCurrent")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMapCurrent)
            PQCSettings.interfacePopoutMapCurrent = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.mapcurrentGeometry)
            PQCWindowGeometry.mapcurrentGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.mapcurrentMaximized)
            PQCWindowGeometry.mapcurrentMaximized = isMax
    }

}
