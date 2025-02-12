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

    id: mapexplorer_window

    //: Window title
    title: qsTranslate("actions", "Map Explorer") + " | PhotoQt"

    geometry: PQCWindowGeometry.mapexplorerGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.mapexplorerMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutMapExplorer // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.mapexplorerForcePopout // qmllint disable unqualified
    source: "actions/PQMapExplorer.qml"

    minimumWidth: 800
    minimumHeight: 600

    modality: PQCSettings.interfacePopoutMapExplorerNonModal ? Qt.NonModal : Qt.ApplicationModal // qmllint disable unqualified

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "mapexplorer") // qmllint disable unqualified
            loader.elementClosed("mapexplorer")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMapExplorer) // qmllint disable unqualified
            PQCSettings.interfacePopoutMapExplorer = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.mapexplorerGeometry) // qmllint disable unqualified
            PQCWindowGeometry.mapexplorerGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.mapexplorerMaximized) // qmllint disable unqualified
            PQCWindowGeometry.mapexplorerMaximized = isMax
    }

}
