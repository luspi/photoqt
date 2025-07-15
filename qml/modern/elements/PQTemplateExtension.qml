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

    property ExtensionSettings settings: element_top.settings

    // will be set automatically
    property string extensionId: extension_container.extensionId

    ///////////////////

    ///////////////////
    // these are user facing options

    // property bool setHideDuringSlideshow: true
    // property bool setAllowResizing: true
    // property bool setCanBePoppedOut: true
    // property bool setHandleForegroundMouseEvent: true
    // property bool setAnchorInTopMiddle: false
    // property string setTooltip: ""

    width: parent.parent.width
    height: parent.parent.height

    ///////////////////

    property string getExtensionBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)
    // property bool getDragActive: mousearea.drag.active || mouseareaBG.drag.active
    // property bool getResizeActive: resizearea.pressed
    // property bool getIsMovedManually: false

    ///////////////////
    // user facing accessors

    property alias content: contentItem.children

    ///////////////////
    // some user facing signals

    signal leftClicked(var mouse)
    signal rightClicked(var mouse)
    signal showing()
    signal hiding()

    ///////////////////

    // onGetDragActiveChanged: {
        // if(getDragActive)
            // getIsMovedManually = true
    // }

    color: PQCLook.baseColor

    Item {

        id: contentItem

        width: extension_top.width
        height: extension_top.height

        clip: true

        // CONTENT WILL GO HERE

    }


    Component.onCompleted: {
        if(extensionId == "") {
            PQCScriptsConfig.inform("Faulty extension!", "An extension was added that is missing its extension id! This is bad and needs to be fixed!")
            return
        }
    }

    function hide() {
        element_top.hide()
    }

}
