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

Loader {

    id: loaderset_top

    property bool isModern: PQCSettings.generalInterfaceVariant==="modern"

    active: false
    anchors.fill: parent
    sourceComponent: ((PQCSettings.interfacePopoutSettingsManager || PQCWindowGeometry.settingsmanagerForcePopout || !loaderset_top.isModern) ? comp_settingsmanager_popout : comp_settingsmanager)

    Component {
        id: comp_settingsmanager
        PQTemplateModal {
            id: smmod
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
            content: PQSettingsManager {
                id: tmpl
                button1: smmod.button1
                button2: smmod.button2
                button3: smmod.button3
                bottomLeft: smmod.bottomLeft
                popInOutButton: smmod.popInOutButton
                availableHeight: smmod.contentHeight - (loaderset_top.isModern ? (smmod.bottomrowHeight+smmod.toprowHeight) : 0)
                Component.onCompleted: {
                    smmod.elementId = elementId
                    smmod.title = title
                    smmod.letElementHandleClosing = letMeHandleClosing
                    smmod.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }
    Component {
        id: comp_settingsmanager_popout
        PQTemplateModalPopout {
            id: smpop
            defaultPopoutGeometry: PQCWindowGeometry.settingsmanagerGeometry
            defaultPopoutMaximized: PQCWindowGeometry.settingsmanagerMaximized
            popInOutButton.visible: loaderset_top.isModern
            function showing() { return tmpl.showing() }
            function hiding() { return tmpl.hiding() }
            onRectUpdated: (r) => {
                PQCWindowGeometry.settingsmanagerGeometry = r
            }
            onMaximizedUpdated: (m) => {
                PQCWindowGeometry.settingsmanagerMaximized = m
            }
            content: PQSettingsManager {
                id: tmpl
                button1: smpop.button1
                button2: smpop.button2
                button3: smpop.button3
                bottomLeft: smpop.bottomLeft
                popInOutButton: smpop.popInOutButton
                availableHeight: smpop.contentHeight - (loaderset_top.isModern ? (smpop.bottomrowHeight+smpop.toprowHeight) : 0)
                Component.onCompleted: {
                    smpop.elementId = elementId
                    smpop.title = title
                    smpop.letElementHandleClosing = letMeHandleClosing
                    smpop.bottomLeftContent = bottomLeftContent
                }
            }
        }
    }

}
