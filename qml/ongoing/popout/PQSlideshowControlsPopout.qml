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
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: histogram_popout

    //: Window title
    title: qsTranslate("slideshow", "Slideshow")

    geometry: PQCWindowGeometry.slideshowcontrolsGeometry
    isMax: PQCWindowGeometry.slideshowcontrolsMaximized
    popout: PQCSettings.interfacePopoutSlideshowControls
    sizepopout: PQCWindowGeometry.slideshowcontrolsForcePopout
    source: "ongoing/PQSlideshowControls.qml"

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        close()
        loader_slideshowhandler.item.hide()
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutSlideshowControls)
            PQCSettings.interfacePopoutSlideshowControls = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.slideshowcontrolsGeometry)
            PQCWindowGeometry.slideshowcontrolsGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.slideshowcontrolsMaximized)
            PQCWindowGeometry.slideshowcontrolsMaximized = isMax
    }

}
