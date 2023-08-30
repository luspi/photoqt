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
import PQCNotify
import "../../elements"

PQTemplatePopout {

    id: filedialog_window

    //: Window title
    title: qsTranslate("actions", "File Dialog")

    geometry: PQCPopoutGeometry.filedialogGeometry
    isMax: PQCPopoutGeometry.filedialogMaximized
    popout: PQCSettings.interfacePopoutFileDialog
    sizepopout: PQCPopoutGeometry.filedialogForcePopout
    source: "filedialog/PQFileDialog.qml"

    flags: Qt.Window|Qt.WindowStaysOnTopHint
    modality: PQCSettings.interfacePopoutFileDialogKeepOpen ? Qt.NonModal : Qt.ApplicationModal

    minimumWidth: 400
    minimumHeight: 600

    onPopoutClosed: {
        loader.elementClosed("filedialog")
    }

    onGeometryChanged: {
        if(geometry !== PQCPopoutGeometry.filedialogGeometry)
            PQCPopoutGeometry.filedialogGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCPopoutGeometry.filedialogMaximized)
            PQCPopoutGeometry.filedialogMaximized = isMax
    }

}
