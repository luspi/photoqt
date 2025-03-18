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
import PQCNotify

import "../../qml/elements"

PQTemplatePopout {

    id: quickactions_popout

    //: Window title
    title: qsTranslate("quickactions", "Quick Actions") + " | PhotoQt"

    geometry: Qt.rect(0,0,100,100)
    isMax: false
    popout: PQCSettings.interfacePopoutQuickActions // qmllint disable unqualified
    sizepopout: PQCWindowGeometry.quickactionsForcePopout // qmllint disable unqualified
    source: "ongoing/PQQuickActions.qml"

    modality: Qt.NonModal

    minimumWidth: 100
    minimumHeight: 100

    onPopoutClosed: {
        PQCSettings.interfacePopoutQuickActions = false // qmllint disable unqualified
        close()
        PQCNotify.executeInternalCommand("__quickActions")
    }

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutQuickActions) // qmllint disable unqualified
            PQCSettings.interfacePopoutQuickActions = popout
    }

}
