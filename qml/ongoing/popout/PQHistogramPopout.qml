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

    id: histogram_window

    //: Window title
    title: qsTranslate("histogram", "Histogram")

    geometry: PQCPopoutGeometry.histogramGeometry
    isMax: PQCPopoutGeometry.histogramMaximized
    popout: PQCSettings.interfacePopoutHistogram
    sizepopout: PQCPopoutGeometry.histogramForcePopout
    source: "ongoing/PQHistogram.qml"

    flags: Qt.Window|Qt.WindowStaysOnTopHint
    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        PQCSettings.interfacePopoutHistogram = false
        close()
        PQCNotify.executeInternalCommand("__histogram")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutHistogram)
            PQCSettings.interfacePopoutHistogram = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.histogramGeometry)
            PQCPopoutGeometry.histogramGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.histogramMaximized)
            PQCPopoutGeometry.histogramMaximized = isMax
    }

}
