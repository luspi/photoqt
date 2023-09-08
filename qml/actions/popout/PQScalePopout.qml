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
import "../../elements"

PQTemplatePopout {

    id: scalepopout_top

    //: Window title
    title: qsTranslate("scale", "Scale image")

    geometry: PQCPopoutGeometry.scaleGeometry
    isMax: PQCPopoutGeometry.scaleMaximized
    popout: PQCSettings.interfacePopoutScale
    sizepopout: PQCPopoutGeometry.scaleForcePopout
    source: "actions/PQScale.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed:
        loader.elementClosed("scale")

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutScale)
            PQCSettings.interfacePopoutScale = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.scaleGeometry)
            PQCPopoutGeometry.scaleGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.scaleMaximized)
            PQCPopoutGeometry.scaleMaximized = isMax
    }

}
