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
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: filerename_popout

    //: Window title
    title: qsTranslate("filemanagement", "Rename file") + " | PhotoQt"

    geometry: PQCWindowGeometry.filerenameGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.filerenameMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutFileRename // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.filerenameForcePopout // qmllint disable unqualified
    source: "actions/PQRename.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("filerename")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutFileRename) // qmllint disable unqualified
            PQCSettings.interfacePopoutFileRename = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.filerenameGeometry) // qmllint disable unqualified
            PQCWindowGeometry.filerenameGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.filerenameMaximized) // qmllint disable unqualified
            PQCWindowGeometry.filerenameMaximized = isMax
    }

}
