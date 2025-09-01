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

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Column {

    id: setctrl

    width: parent.width

    property alias content: contcol.children
    property int contentWidth: contcol.width
    property int availableHeight: 0
    property int contentSpacing: contcol.spacing
    property int indentWidth: spacer.width

    property bool showResetButton: true

    property bool disabledAutoIndentation: false
    property bool addBlankSpaceBottom: true

    property bool settingsLoaded: false
    property bool thisSettingHasChanged: false

    signal resetToDefaults()

    spacing: 10

    Row {

        PQSettingSpacer { id: spacer; disabledAutoIndentation: setctrl.disabledAutoIndentation }

        Column {

            id: contcol

            spacing: 10

            width: setctrl.width-spacer.width

        }

    }

    Loader {
        active: setctrl.addBlankSpaceBottom
        sourceComponent:
        Item {
            width: 1
            height: 40
        }
    }

    // PQButtonIcon {
    //     id: resetbutton
    //     x: setctrl.rightcol - width - 10
    //     width: 20
    //     height: 20
    //     visible: setctrl.showResetButton
    //     opacity: hovered ? 1 : 0.5
    //     Behavior on opacity { NumberAnimation { duration: 200 } }
    //     source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
    //     tooltip: qsTranslate("settingsmanager", "reset to default values")
    //     onClicked: (pos) => {
    //         setctrl.resetToDefaults()
    //     }
    // }

    Component.onCompleted:
        load()

    Connections {

        target: PQCNotify

        function onSettingsmanagerSendCommand(what : string, args : list<var>) {
            if(what === "applychanges")
                setctrl.applyChanges()
            else if(what === "loadcurrent")
                setctrl.load()

        }
    }

    function handleEscape() {}
    function checkForChanges() {}
    function load() {}
    function applyChanges() {}


}
