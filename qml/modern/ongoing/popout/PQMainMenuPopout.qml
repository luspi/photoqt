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
import PhotoQt.Modern
import PhotoQt.Shared

PQTemplatePopout {

    id: mainmenu_popout

    //: Window title
    title: qsTranslate("actions", "Main Menu") + " | PhotoQt"

    geometry: PQCWindowGeometry.mainmenuGeometry
    originalGeometry: PQCWindowGeometry.mainmenuGeometry
    isMax: PQCWindowGeometry.mainmenuMaximized
    popout: PQCSettings.interfacePopoutMainMenu
    sizepopout: PQCWindowGeometry.mainmenuForcePopout
    source: "ongoing/PQMainMenu.qml"

    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 600

    onPopoutClosed: {
        PQCSettings.interfacePopoutMainMenu = false
        close()
        PQCScriptsShortcuts.executeInternalCommand("__showMainMenu")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutMainMenu)
            PQCSettings.interfacePopoutMainMenu = popout
    }

    onGeometryChanged: {
        // Note: needs to be handled this way for proper aot compilation
        if(geometry.width !== originalGeometry.width || geometry.height !== originalGeometry.height)
            PQCWindowGeometry.mainmenuGeometry = geometry
    }

    onIsMaxChanged: {
        if(isMax !== PQCWindowGeometry.mainmenuMaximized)
            PQCWindowGeometry.mainmenuMaximized = isMax
    }

}
