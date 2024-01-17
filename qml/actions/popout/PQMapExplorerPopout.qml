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

    id: mapexplorer_window

    //: Window title
    title: qsTranslate("actions", "Map Explorer")

    geometry: PQCWindowGeometry.mapexplorerGeometry
    isMax: PQCWindowGeometry.mapexplorerMaximized
    popout: PQCSettings.interfacePopoutMapExplorer
    sizepopout: PQCWindowGeometry.mapexplorerForcePopout
    source: "actions/PQMapExplorer.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "mapexplorer")
            loader.elementClosed("mapexplorer")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMapExplorer)
            PQCSettings.interfacePopoutMapExplorer = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.mapexplorerGeometry)
            PQCWindowGeometry.mapexplorerGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.mapexplorerMaximized)
            PQCWindowGeometry.mapexplorerMaximized = isMax
    }

}
