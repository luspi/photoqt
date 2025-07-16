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
import PQCScriptsConfig
import ExtensionSettings
import PQCExtensionsHandler

Rectangle {

    id: extension_top

    ///////////////////

    property alias content: contentItem.children
    property ExtensionSettings settings: element_top.settings
    property string baseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)

    property string modalButton1Text: "Close"
    property string modalButton2Text: ""
    property string modalButton3Text: ""

    ///////////////////

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)
    signal showing()
    signal hiding()

    ///////////////////

    property string extensionId: extension_container.extensionId

    ///////////////////
    property bool _fixSizeToContent: ((settings["ExtPopout"] && PQCExtensionsHandler.getExtensionPopoutFixSizeToContent(extensionId)) || (!settings["ExtPopout"] && PQCExtensionsHandler.getExtensionIntegratedFixSizeToContent(extensionId)))

    width: _fixSizeToContent ? contentItem.width : parent.parent.width
    height: _fixSizeToContent ? contentItem.height : parent.parent.height

    color: PQCLook.baseColor
    radius: 5

    Item {

        id: contentItem

        width: _fixSizeToContent ? childrenRect.width : extension_top.width
        height: _fixSizeToContent ? childrenRect.height : extension_top.height

        clip: true

        // CONTENT WILL GO HERE

    }


    Component.onCompleted: {
        if(extensionId == "") {
            PQCScriptsConfig.inform("Faulty extension!", "An extension was added that is missing its extension id! This is bad and needs to be fixed!")
            return
        }
    }

    function modalButton1Action() {
        hide()
    }

    function modalButton2Action() {
    }

    function modalButton3Action() {
    }

    function hide() {
        element_top.hide()
    }

}
