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
import "../../elements"

PQTemplatePopout {

    id: filter_popout

    //: Window title
    title: qsTranslate("filter", "Filter images in current directory")

    geometry: PQCWindowGeometry.filterGeometry
    isMax: PQCWindowGeometry.filterMaximized
    popout: PQCSettings.interfacePopoutFilter
    sizepopout: PQCWindowGeometry.filterForcePopout
    source: "actions/PQFilter.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "filter")
            loader.elementClosed("filter")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutFilter)
            PQCSettings.interfacePopoutFilter = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.filterGeometry)
            PQCWindowGeometry.filterGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.filterMaximized)
            PQCWindowGeometry.filterMaximized = isMax
    }

}
