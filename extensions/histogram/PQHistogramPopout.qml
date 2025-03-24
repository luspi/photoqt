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
import PQCNotify
import PQCExtensionsHandler

import "../../qml/elements"

PQTemplatePopout {

    id: histogram_popout

    //: Window title
    title: qsTranslate("histogram", "Histogram") + " | PhotoQt"

    geometry: Qt.rect(0,0,PQCExtensionsHandler.getDefaultPopoutSize("histogram").width,PQCExtensionsHandler.getDefaultPopoutSize("histogram").height)
    isMax: false
    popout: PQCSettings.extensionsHistogramPopout // qmllint disable unqualified
    sizepopout: minRequiredWindowSize.width > PQCConstants.windowWidth || minRequiredWindowSize.height > PQCConstants.windowHeight // qmllint disable unqualified
    source: "../extensions/histogram/PQHistogram.qml"
    property size minRequiredWindowSize: PQCExtensionsHandler.getMinimumRequiredWindowSize("histogram")

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        if(PQCConstants.photoQtShuttingDown) return
        PQCSettings.extensionsHistogramPopout = false // qmllint disable unqualified
        close()
        PQCNotify.executeInternalCommand("__histogram")
    }

    onPopoutChanged: {
        if(PQCConstants.photoQtShuttingDown) return
        if(popout !== PQCSettings.extensionsHistogramPopout) // qmllint disable unqualified
            PQCSettings.extensionsHistogramPopout = popout
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
