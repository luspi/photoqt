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
import "../../elements"

PQTemplatePopout {

    id: scale_popout

    //: Window title
    title: qsTranslate("scale", "Scale image")

    geometry: PQCWindowGeometry.scaleGeometry
    isMax: PQCWindowGeometry.scaleMaximized
    popout: PQCSettings.interfacePopoutScale
    sizepopout: PQCWindowGeometry.scaleForcePopout
    source: "actions/PQScale.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "scale")
            loader.elementClosed("scale")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutScale)
            PQCSettings.interfacePopoutScale = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.scaleGeometry)
            PQCWindowGeometry.scaleGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.scaleMaximized)
            PQCWindowGeometry.scaleMaximized = isMax
    }

}
