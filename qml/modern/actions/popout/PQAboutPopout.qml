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
import PhotoQt.Modern
import PhotoQt.Shared

PQTemplatePopout {

    id: about_popout

    //: Window title
    title: qsTranslate("actions", "About") + " | PhotoQt"

    geometry: PQCWindowGeometry.aboutGeometry
    originalGeometry: PQCWindowGeometry.aboutGeometry
    isMax: PQCWindowGeometry.aboutMaximized
    popout: PQCSettings.interfacePopoutAbout
    sizepopout: PQCWindowGeometry.aboutForcePopout
    source: "actions/PQAbout.qml"


    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("about")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutAbout) 
            PQCSettings.interfacePopoutAbout = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.aboutGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.aboutMaximized)
            PQCWindowGeometry.aboutMaximized = isMax
    }

}
