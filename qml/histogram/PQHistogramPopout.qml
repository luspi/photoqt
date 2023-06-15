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

import QtQuick 2.9
import "../elements"
import "../templates"

PQTemplatePopout {

    //: Window title
    title: em.pty+qsTranslate("histogram", "Histogram")

    geometry: windowgeometry.histogramWindowGeometry
    isMax: windowgeometry.histogramWindowMaximized
    popup: PQSettings.interfacePopoutHistogram
    sizepopup: false
    name: "histogram"
    source: "histogram/PQHistogram.qml"

    minimumWidth: 300
    minimumHeight: 200

    modality: Qt.NonModal

    onPopupChanged:
        PQSettings.interfacePopoutHistogram = popup

    onGeometryChanged:
        windowgeometry.histogramWindowGeometry = geometry

    onIsMaxChanged:
        windowgeometry.histogramWindowMaximized = isMax

    onPopupClosed:
        PQSettings.histogramVisible = false

}
