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

import PQCWindowGeometry
import "../../elements"

PQTemplatePopout {

    id: crop_popout

    //: Window title
    title: qsTranslate("crop", "Crop image") + " | PhotoQt"

    geometry: PQCWindowGeometry.cropGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.cropMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutCrop // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.cropForcePopout // qmllint disable unqualified
    source: "actions/PQCrop.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "crop") // qmllint disable unqualified
            loader.elementClosed("crop")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutCrop) // qmllint disable unqualified
            PQCSettings.interfacePopoutCrop = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.cropGeometry) // qmllint disable unqualified
            PQCWindowGeometry.cropGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.cropMaximized) // qmllint disable unqualified
            PQCWindowGeometry.cropMaximized = isMax
    }

}
