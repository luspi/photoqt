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
import PhotoQt.Modern

PQTemplatePopout {

    id: advancedsort_popout

    //: Window title
    title: qsTranslate("advancedsort", "Advanced image sort") + " | PhotoQt"

    geometry: PQCWindowGeometry.advancedsortGeometry
    originalGeometry: PQCWindowGeometry.advancedsortGeometry
    isMax: PQCWindowGeometry.advancedsortMaximized
    popout: PQCSettings.interfacePopoutAdvancedSort
    sizepopout: PQCWindowGeometry.advancedsortForcePopout
    source: "actions/PQAdvancedSort.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("advancedsort")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutAdvancedSort)
            PQCSettings.interfacePopoutAdvancedSort = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.advancedsortGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.advancedsortMaximized)
            PQCWindowGeometry.advancedsortMaximized = isMax
    }

    function doSorting() {
        return loaderitem.doSorting() 
    }

}
