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
import QtQuick.Controls
import PhotoQt.Modern
import PhotoQt.Shared
import PQCExtensionsHandler

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    signal loadSettings()
    signal saveSettings()

    Column {

        id: contcol

        spacing: 10
        width: parent.width

        PQText {
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTranslate("settingsmanager", "Settings for all enabled extensions.")
        }

        Repeater {
            id: rptr
            width: contcol.width
            property list<string> ext: PQCExtensionsHandler.getExtensions()
            model: ext.length
            Loader {
                id: ldr
                width: contcol.width
                required property int modelData
                property string e: rptr.ext[modelData]
                active: PQCExtensionsHandler.getHasSettings(e)
                source: "file:/" + PQCExtensionsHandler.getExtensionLocation(e) + "/modern/PQ" + e + "Settings.qml"
                onStatusChanged: {
                    if(active && status == Loader.Ready) {
                        item.loadSettings()
                    }
                }
                Connections {
                    target: setting_top
                    enabled: PQCExtensionsHandler.getHasSettings(e)
                    function onLoadSettings() {
                        ldr.item.loadSettings()
                    }
                    function onSaveSettings() {
                        ldr.item.saveSettings()
                    }
                }
                Connections {
                    target: ldr.item
                    enabled: ldr.status===Loader.Ready
                    function onHasChanged() {
                        if(PQCSettings.generalAutoSaveSettings)
                            setting_top.applyChanges()
                        else
                            setting_top.settingChanged = true
                    }
                }
            }

        }

    }

    Component.onCompleted:
        load()

    function handleEscape() {
    }

    function load() {

        setting_top.loadSettings()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        setting_top.saveSettings()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
