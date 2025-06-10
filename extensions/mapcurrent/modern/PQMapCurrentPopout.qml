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

    id: mapcurrent_popout

    //: Window title
    title: qsTranslate("mapcurrent", "Current location") + " | PhotoQt"

    geometry: Qt.rect(0,0,PQCExtensionsHandler.getDefaultPopoutSize("mapcurrent").width,PQCExtensionsHandler.getDefaultPopoutSize("mapcurrent").height)
    originalGeometry: PQCWindowGeometry.mapcurrentGeometry
    isMax: false
    popout: PQCSettingsExtensions.MapCurrentPopout
    sizepopout: minRequiredWindowSize.width > PQCConstants.windowWidth || minRequiredWindowSize.height > PQCConstants.windowHeight
    source: "../../extensions/mapcurrent/modern/PQMapCurrent.qml"
    property size minRequiredWindowSize: PQCExtensionsHandler.getMinimumRequiredWindowSize("mapcurrent")

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        if(PQCConstants.photoQtShuttingDown) return
        PQCSettingsExtensions.MapCurrentPopout = false
        close()
        PQCNotify.executeInternalCommand("__showMapCurrent")
    }

    onPopoutChanged: {
        if(PQCConstants.photoQtShuttingDown) return
        if(popout !== PQCSettingsExtensions.MapCurrentPopout)
            PQCSettingsExtensions.MapCurrentPopout = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.mapcurrentGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.mapcurrentMaximized)
            PQCWindowGeometry.mapcurrentMaximized = isMax
    }

}
