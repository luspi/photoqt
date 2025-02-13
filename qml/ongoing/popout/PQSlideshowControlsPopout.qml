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
import "../../elements"

PQTemplatePopout {

    id: slideshowcontrols_popout

    //: Window title
    title: qsTranslate("slideshow", "Slideshow") + " | PhotoQt"

    geometry: PQCWindowGeometry.slideshowcontrolsGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.slideshowcontrolsMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutSlideshowControls // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.slideshowcontrolsForcePopout // qmllint disable unqualified
    source: "ongoing/PQSlideshowControls.qml"

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        close()
        loader_slideshowhandler.item.hide() // qmllint disable unqualified
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutSlideshowControls) // qmllint disable unqualified
            PQCSettings.interfacePopoutSlideshowControls = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.slideshowcontrolsGeometry) // qmllint disable unqualified
            PQCWindowGeometry.slideshowcontrolsGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.slideshowcontrolsMaximized) // qmllint disable unqualified
            PQCWindowGeometry.slideshowcontrolsMaximized = isMax
    }

}
