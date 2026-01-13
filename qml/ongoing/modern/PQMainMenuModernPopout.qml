/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

Window {

    id: mainmenu_popout

    //: Window title
    title: qsTranslate("actions", "Main Menu") + " | PhotoQt"

    PQMainMenuModern {
        id: mainmenu
        setVisible: true
        state: "popout"
    }

    modality: Qt.NonModal

    minimumWidth: 400
    minimumHeight: 600

    color: "transparent"

    onClosing: {
        if(!PQCConstants.photoQtShuttingDown)
            PQCSettings.interfacePopoutMainMenu = false
        PQCConstants.mainmenuShowWhenReady = true
    }

    onWidthChanged: {
        if(width != PQCSettings.mainmenuElementSize.width)
            PQCSettings.mainmenuElementSize.width = width
        mainmenu.parentWidth = width
    }
    onHeightChanged: {
        if(height != PQCSettings.mainmenuElementSize.height)
            PQCSettings.mainmenuElementSize.height = height
        mainmenu.parentHeight = height
    }
    onXChanged: {
        if(x != PQCSettings.mainmenuElementPosition.x)
            PQCSettings.mainmenuElementPosition.x = x
    }
    onYChanged: {
        if(y != PQCSettings.mainmenuElementPosition.y)
            PQCSettings.mainmenuElementPosition.y = y
    }

    onVisibilityChanged: {
        var isMax = (visibility === Qt.WindowMaximized)
        if(isMax !== PQCWindowGeometry.mainmenuMaximized)
            PQCWindowGeometry.mainmenuMaximized = isMax
    }

    Component.onCompleted: {
        mainmenu_popout.setX(PQCSettings.mainmenuElementPosition.x)
        mainmenu_popout.setY(PQCSettings.mainmenuElementPosition.y)
        mainmenu_popout.setWidth(PQCSettings.mainmenuElementSize.width)
        mainmenu_popout.setHeight(PQCSettings.mainmenuElementSize.height)
        mainmenu.parentWidth = width
        mainmenu.parentHeight = height
        showNormal()
    }

}
