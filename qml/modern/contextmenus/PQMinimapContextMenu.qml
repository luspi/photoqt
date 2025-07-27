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

Item {

    PQMenu {

        id: rightclickmenu

        PQMenuItem {
            text: qsTranslate("image", "Small minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 0
        }

        PQMenuItem {
            text: qsTranslate("image", "Normal minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 1
        }

        PQMenuItem {
            text: qsTranslate("image", "Large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 2
        }

        PQMenuItem {
            text: qsTranslate("image", "Very large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 3
        }

        PQMenuSeparator {}

        PQMenuItem {
            text: qsTranslate("image", "Hide minimap")
            onTriggered:
                PQCSettings.imageviewShowMinimap = false
        }

    }

    Connections {

        target: PQCNotify

        function onShowMinimapContextMenu() {
            rightclickmenu.popup()
        }

    }

}
