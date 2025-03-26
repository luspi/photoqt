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

    id: about_popout

    //: Window title
    title: qsTranslate("actions", "About") + " | PhotoQt"

    geometry: PQCWindowGeometry.aboutGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.aboutMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutAbout // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.aboutForcePopout // qmllint disable unqualified
    source: "actions/PQAbout.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("about")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutAbout) // qmllint disable unqualified
            PQCSettings.interfacePopoutAbout = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.aboutGeometry) // qmllint disable unqualified
            PQCWindowGeometry.aboutGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.aboutMaximized) // qmllint disable unqualified
            PQCWindowGeometry.aboutMaximized = isMax
    }

}
