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

    id: histogram_popout

    //: Window title
    title: qsTranslate("histogram", "Histogram") + " | PhotoQt"

    geometry: PQCWindowGeometry.histogramGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.histogramMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutHistogram // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.histogramForcePopout // qmllint disable unqualified
    source: "ongoing/PQHistogram.qml"

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        PQCSettings.interfacePopoutHistogram = false // qmllint disable unqualified
        close()
        PQCNotify.executeInternalCommand("__histogram")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutHistogram) // qmllint disable unqualified
            PQCSettings.interfacePopoutHistogram = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.histogramGeometry) // qmllint disable unqualified
            PQCWindowGeometry.histogramGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.histogramMaximized) // qmllint disable unqualified
            PQCWindowGeometry.histogramMaximized = isMax
    }

}
