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
import PhotoQt

PQTemplatePopout {

    id: crop_popout

    //: Window title
    title: qsTranslate("crop", "Crop image") + " | PhotoQt"

    geometry: PQCWindowGeometry.cropGeometry
    originalGeometry: PQCWindowGeometry.cropGeometry
    isMax: PQCWindowGeometry.cropMaximized
    popout: PQCSettings.extensions.CropImagePopout
    sizepopout: PQCWindowGeometry.cropForcePopout
    source: "../../extensions/cropimage/modern/PQCropImage.qml"

    minimumWidth: 800
    minimumHeight: 600

    Connections {
        target: PQCSettings
        function onExtensionSettingUpdated(key : string, val : var) : void {
            if(key === "CropImagePopout" && crop_popout.popout !== val)
                crop_popout.popout = val
        }
    }

    onPopoutClosed: {
        PQCNotify.loaderRegisterClose("cropimage")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.extensions.CropImagePopout)
            PQCSettings.extensions.CropImagePopout = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.cropGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.cropMaximized)
            PQCWindowGeometry.cropMaximized = isMax
    }

}
