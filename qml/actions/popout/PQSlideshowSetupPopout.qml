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

    id: slideshowsetup_popout

    //: Window title
    title: qsTranslate("slideshow", "Slideshow setup")

    geometry: PQCPopoutGeometry.slideshowsetupGeometry
    isMax: PQCPopoutGeometry.slideshowsetupMaximized
    popout: PQCSettings.interfacePopoutSlideshowSetup
    sizepopout: PQCPopoutGeometry.slideshowsetupForcePopout
    source: "actions/PQSlideshowSetup.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "slideshowsetup")
            loader.elementClosed("slideshowsetup")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutSlideshowSetup)
            PQCSettings.interfacePopoutSlideshowSetup = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.slideshowsetupGeometry)
            PQCPopoutGeometry.slideshowsetupGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.slideshowsetupMaximized)
            PQCPopoutGeometry.slideshowsetupMaximized = isMax
    }

}
