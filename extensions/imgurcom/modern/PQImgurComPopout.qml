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

PQTemplatePopout {

    id: imgur_popout

    //: Window title
    title: qsTranslate("imgur", "Upload to imgur.com") + " | PhotoQt"

    geometry: PQCWindowGeometry.imgurGeometry
    originalGeometry: PQCWindowGeometry.imgurGeometry
    isMax: PQCWindowGeometry.imgurMaximized
    popout: PQCSettingsExtensions.ImgurComPopout
    sizepopout: PQCWindowGeometry.imgurForcePopout
    source: "../../extensions/imgurcom/modern/PQImgurCom.qml"

    minimumWidth: 800
    minimumHeight: 600

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("imgurcom")
    }

    onPopoutChanged: {
        if(popout !== PQCSettingsExtensions.ImgurComPopout)
            PQCSettingsExtensions.ImgurComPopout = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.imgurGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.imgurMaximized)
            PQCWindowGeometry.imgurMaximized = isMax
    }

    function uploadAnonymously() {
        loaderitem.uploadAnonymously() // qmllint disable missing-property
    }

    function uploadToAccount() {
        loaderitem.uploadToAccount() // qmllint disable missing-property
    }

}
