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
import "../../elements"

PQTemplatePopout {

    id: filedialog_window

    //: Window title
    title: qsTranslate("actions", "File Dialog") + " | PhotoQt"

    geometry: PQCWindowGeometry.filedialogGeometry // qmllint disable unqualified
    isMax: PQCWindowGeometry.filedialogMaximized // qmllint disable unqualified
    popout: PQCSettings.interfacePopoutFileDialog // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.filedialogForcePopout // qmllint disable unqualified
    source: "filedialog/PQFileDialog.qml"

    modality: PQCSettings.interfacePopoutFileDialogNonModal ? Qt.NonModal : Qt.ApplicationModal // qmllint disable unqualified

    minimumWidth: 400
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("filedialog")
        PQCNotify.loaderPassOn("forceClose", []) // qmllint disable unqualified
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.filedialogGeometry) // qmllint disable unqualified
            PQCWindowGeometry.filedialogGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.filedialogMaximized) // qmllint disable unqualified
            PQCWindowGeometry.filedialogMaximized = isMax
    }

}
