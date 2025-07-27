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
import PhotoQt.Integrated
import PhotoQt.Shared

Item {

    PQMenu {

        id: rightclickmenu

        property bool resetPosAfterHide: false

        PQMenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
            text: qsTranslate("image", PQCSettings.filetypesDocumentLeftRight ? "Unlock arrow keys" : "Lock arrow keys")
            onTriggered: {
                PQCSettings.filetypesDocumentLeftRight = !PQCSettings.filetypesDocumentLeftRight
            }
        }

        PQMenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg"
            text: qsTranslate("image", "Viewer mode")
            onTriggered: {
                PQCFileFolderModel.enableViewerMode(PQCConstants.currentFileInsideNum)
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
            text: qsTranslate("image", "Reset position")
            onTriggered: {
                rightclickmenu.resetPosAfterHide = true
            }
        }

        PQMenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
            text: qsTranslate("image", "Hide controls")
            onTriggered:
                PQCSettings.filetypesDocumentControls = false
        }

        onVisibleChanged: {
            if(!visible && resetPosAfterHide) {
                resetPosAfterHide = false
                PQCNotify.currentDocumentControlsResetPosition()
            }
        }

    }

    Connections {

        target: PQCNotify

        function onShowDocumentControlsContextMenu() {
            rightclickmenu.popup()
        }

    }

}
