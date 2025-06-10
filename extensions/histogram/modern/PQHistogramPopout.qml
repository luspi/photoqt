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
import PQCExtensionsHandler
import org.photoqt.qml

import "../../../qml/modern/elements"

PQTemplatePopout {

    id: histogram_popout

    //: Window title
    title: qsTranslate("histogram", "Histogram") + " | PhotoQt"

    geometry: Qt.rect(0,0,PQCExtensionsHandler.getDefaultPopoutSize("histogram").width,PQCExtensionsHandler.getDefaultPopoutSize("histogram").height)
    originalGeometry: PQCWindowGeometry.histogramGeometry
    isMax: false
    popout: PQCSettingsExtensions.HistogramPopout
    sizepopout: minRequiredWindowSize.width > PQCConstants.windowWidth || minRequiredWindowSize.height > PQCConstants.windowHeight
    source: "../../extensions/histogram/modern/PQHistogram.qml"
    property size minRequiredWindowSize: PQCExtensionsHandler.getMinimumRequiredWindowSize("histogram")

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        if(PQCConstants.photoQtShuttingDown) return
        PQCSettingsExtensions.HistogramPopout = false
        close()
        PQCNotify.executeInternalCommand("__histogram")
    }

    onPopoutChanged: {
        if(PQCConstants.photoQtShuttingDown) return
        if(popout !== PQCSettingsExtensions.HistogramPopout)
            PQCSettingsExtensions.HistogramPopout = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.histogramGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.histogramMaximized)
            PQCWindowGeometry.histogramMaximized = isMax
    }

}
