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

    id: filedialog_window

    //: Window title
    title: qsTranslate("actions", "File Dialog")

    geometry: PQCWindowGeometry.filedialogGeometry
    isMax: PQCWindowGeometry.filedialogMaximized
    popout: PQCSettings.interfacePopoutFileDialog
    sizepopout: PQCWindowGeometry.filedialogForcePopout
    source: "filedialog/PQFileDialog.qml"

    modality: PQCSettings.interfacePopoutFileDialogKeepOpen ? Qt.NonModal : Qt.ApplicationModal

    minimumWidth: 400
    minimumHeight: 600

    onPopoutClosed: {
        loader.passOn("forceClose", [])
    }

    onGeometryChanged: {
        if(geometry !== PQCWindowGeometry.filedialogGeometry)
            PQCWindowGeometry.filedialogGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.filedialogMaximized)
            PQCWindowGeometry.filedialogMaximized = isMax
    }

}
