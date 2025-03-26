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

    id: slideshowsetup_popout

    //: Window title
    title: qsTranslate("slideshow", "Slideshow setup") + " | PhotoQt"

    geometry: PQCWindowGeometry.slideshowsetupGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.slideshowsetupMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutSlideshowSetup // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.slideshowsetupForcePopout // qmllint disable unqualified
    source: "actions/PQSlideshowSetup.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("slideshowsetup")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutSlideshowSetup) // qmllint disable unqualified
            PQCSettings.interfacePopoutSlideshowSetup = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.slideshowsetupGeometry) // qmllint disable unqualified
            PQCWindowGeometry.slideshowsetupGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.slideshowsetupMaximized) // qmllint disable unqualified
            PQCWindowGeometry.slideshowsetupMaximized = isMax
    }

}
