/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtQuick.Controls

import PQCScriptsConfig

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    property bool settingChanged: false

    ScrollBar.vertical: PQVerticalScrollBar {}

    Column {

        id: contcol

        x: (parent.width-width)/2

        spacing: 10

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Export/Import configuration")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Here you can create a backup of the configuration for backup or for moving it to another install of PhotoQt. You can import a local backup below. After importing a backup file PhotoQt will automatically close as it will need to be restarted for the changes to take effect.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 1
        }

        PQButton {
            id: config_export
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "export configuration")
            onClicked:
                PQCScriptsConfig.exportConfigTo("")
        }

        Item {
            width: 1
            height: 1
        }

        PQButton {
            id: config_import
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "import configuration")
            onClicked: {
                PQCScriptsConfig.importConfigFrom("")
                PQCScriptsConfig.inform(qsTranslate("settingsmanager", "Restart required"),
                                        qsTranslate("settingsmanager", "PhotoQt will now quit as it needs to be restarted for the changes to take effect."))
                toplevel.quitPhotoQt()
            }
        }

        /**********************************************************************/

        Item {
            width: 1
            height: 1
        }


    }

    Component.onCompleted:
        load()

    function checkDefault() {}

    function load() {}

    function applyChanges() {}

    function revertChanges() {
        load()
    }

}
