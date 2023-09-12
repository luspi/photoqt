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

    id: exportpopout_top

    //: Window title
    title: qsTranslate("actions", "About")

    geometry: PQCPopoutGeometry.aboutGeometry
    isMax: PQCPopoutGeometry.aboutMaximized
    popout: PQCSettings.interfacePopoutAbout
    sizepopout: PQCPopoutGeometry.aboutForcePopout
    source: "actions/PQAbout.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        // without the check it might spit out a warning at app quit
        if(loader.visibleItem === "about")
            loader.elementClosed("about")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutAbout)
            PQCSettings.interfacePopoutAbout = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.aboutGeometry)
            PQCPopoutGeometry.aboutGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.aboutMaximized)
            PQCPopoutGeometry.aboutMaximized = isMax
    }

}
