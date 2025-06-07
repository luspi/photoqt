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

import org.photoqt.qml

import "../../../qml/modern/elements"

PQTemplatePopout {

    id: export_popout

    //: Window title
    title: qsTranslate("actions", "Export image") + " | PhotoQt"

    geometry: PQCWindowGeometry.exportGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.exportMaximized // qmllint disable unqualified
    popout: PQCSettings.extensionsExportImagePopout // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.exportForcePopout // qmllint disable unqualified
    source: "../../extensions/exportimage/modern/PQExportImage.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("exportimage")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.extensionsExportImagePopout) // qmllint disable unqualified
            PQCSettings.extensionsExportImagePopout = popout
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.exportGeometry) // qmllint disable unqualified
            PQCWindowGeometry.exportGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.exportMaximized) // qmllint disable unqualified
            PQCWindowGeometry.exportMaximized = isMax
    }

}
