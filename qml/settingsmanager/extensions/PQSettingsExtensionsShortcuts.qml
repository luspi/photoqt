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
import PQCExtensionsHandler
import "../../other/PQCommonFunctions.js" as PQF

PQSetting {

    id: set_exsh

    property list<string> allExtensions
    property list<string> extensionsEnabled
    property list<string> extensionsDisabled

    property var ext2Sh: ({})

    SystemPalette { id: pqtPalette }

    property int extensionIdIndexForDetectingNewShortcut: -1

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Extension Shortcuts")

            helptext: qsTranslate("settingsmanager",  "Every extension can have a shortcut associated with it. Triggering the shortcut will either show/hide the floating extension or show a modal extension. If a shortcut is also in use for any internal function, then that action will have priority and the extension will not be activated.")

            showLineAbove: false

        },

        Item {

            width: parent.width
            height: noext.height+20
            visible: set_exsh.allExtensions.length===0

            PQTextL {
                id: noext
                y: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.weight: PQCLook.fontWeightBold
                enabled: false
                font.italic: true
                text: qsTranslate("settingsmanager", "No extensions installed")
            }

        },

        Column {

            id: col

            width: parent.width

            spacing: 10

            property int maxWidth: 20

            Repeater {
                model: set_exsh.allExtensions.length

                Rectangle {

                    id: deleg

                    required property int index
                    property string extensionId: set_exsh.allExtensions[index]

                    opacity: extEnabled ? 1 : 0.6
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    property string extVersion: PQCExtensionsHandler.getExtensionVersion(extensionId)
                    property string extName: PQCExtensionsHandler.getExtensionName(extensionId)
                    property string extDesc: PQCExtensionsHandler.getExtensionDescription(extensionId)
                    property string extAuthor: PQCExtensionsHandler.getExtensionAuthor(extensionId)
                    property string extContact: PQCExtensionsHandler.getExtensionContact(extensionId)
                    property string extWebsite: PQCExtensionsHandler.getExtensionWebsite(extensionId)
                    property string extBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)
                    property string extShortcut: set_exsh.ext2Sh[extensionId]

                    property bool extEnabled: set_exsh.extensionsEnabled.indexOf(extensionId)>-1

                    property string tooltipText: (extEnabled ? "" : "<b><i>currently disabled</i></b>") +
                                                 "<h2>" + deleg.extName + "</h2>
                                                 <b>" + qsTranslate("settingsmanager", "Version") + ":</b> " + extVersion + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Author") + ":</b> " + extAuthor + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Contact") + ":</b> " + extContact + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Website:") + "</b> " + extWebsite + "<br><br>
                                                 <b>" + qsTranslate("settingsmanager", "Loaded from") + ":</b><br>" + extBaseDir

                    width: col.width
                    height: 40
                    color: pqtPalette.alternateBase
                    clip: true

                    Row {

                        x: 10
                        height: parent.height

                        spacing: 20

                        PQText {
                            id: extTitle
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            text: deleg.extName
                            font.strikeout: !deleg.extEnabled
                            font.weight: PQCLook.fontWeightBold
                            onWidthChanged: {
                                if(width > col.maxWidth)
                                    col.maxWidth = width
                                width = Qt.binding(function() { return col.maxWidth })
                            }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.WhatsThisCursor
                                text: deleg.tooltipText
                            }
                        }

                        PQButton {
                            id: shortcutButton
                            y: (parent.height-height)/2
                            text: deleg.extShortcut
                            onTextChanged:
                                deleg.checkDuplicate(text)
                            onClicked: {
                                set_exsh.extensionIdIndexForDetectingNewShortcut = deleg.index
                                if(deleg.extShortcut === "")
                                    PQCNotify.settingsmanagerSendCommand("newShortcut", [deleg.index])
                                else
                                    PQCNotify.settingsmanagerSendCommand("changeShortcut", [deleg.extShortcut, deleg.index, deleg.index])
                            }
                        }

                        PQText {
                            id: errExt
                            y: (parent.height-height)/2
                            width: deleg.width - extTitle.width-shortcutButton.width - 50
                            elide: Text.ElideRight
                            visible: false
                            font.weight: PQCLook.fontWeightBold
                            property string errSh: ""
                            text: "The chosen shortcut (%1) is already in use by another extension.".arg(errSh)
                        }

                        PQText {
                            id: errExtDef
                            y: (parent.height-height)/2
                            width: deleg.width - extTitle.width-shortcutButton.width - 50
                            elide: Text.ElideRight
                            visible: false
                            font.weight: PQCLook.fontWeightBold
                            property string errSh: ""
                            text: "This shortcut is already in use by another extension and will not do anything."
                        }

                        PQText {
                            id: errInt
                            y: (parent.height-height)/2
                            width: deleg.width - extTitle.width-shortcutButton.width - 50
                            elide: Text.ElideRight
                            visible: false
                            font.weight: PQCLook.fontWeightBold
                            property string errSh: ""
                            text: "The chosen shortcut (%1) is already in use internally and cannot be used.".arg(errSh)
                        }

                        PQText {
                            id: errIntDef
                            y: (parent.height-height)/2
                            width: deleg.width - extTitle.width-shortcutButton.width - 50
                            elide: Text.ElideRight
                            visible: false
                            font.weight: PQCLook.fontWeightBold
                            property string errSh: ""
                            text: "This shortcut is already in use internally and will not do anything."
                        }

                    }

                    function checkDuplicate(sh : string) : bool {
                        var extExisting = PQCExtensionsHandler.getExtensionForShortcut(sh)
                        if(PQCShortcuts.getNumberExternalCommandsForShortcut(sh) > 0 || PQCShortcuts.getNumberInternalCommandsForShortcut(sh) > 0) {
                            if(deleg.extShortcut === sh) {
                                errIntDef.errSh = sh
                                errIntDef.visible = true
                            } else {
                                errInt.errSh = sh
                                errInt.visible = true
                            }
                            return true
                        } else if(extExisting !== "" && extExisting !== deleg.extensionId) {
                            if(deleg.extShortcut === sh) {
                                errExtDef.errSh = sh
                                errExtDef.visible = true
                            } else {
                                errExt.errSh = sh
                                errExt.visible = true
                            }

                            return true
                        } else {
                            errInt.visible = false
                            errExt.visible = false
                            errIntDef.visible = false
                            errExtDef.visible = false
                            return false
                        }
                    }

                    Connections {

                        target: PQCNotify

                        function onSettingsmanagerSendCommand(what : string, args : list<var>) {
                            if(what === "newShortcut" && set_exsh.extensionIdIndexForDetectingNewShortcut == deleg.index) {

                                var c = args[2]

                                if(!deleg.checkDuplicate(c)) {
                                    set_exsh.ext2Sh[extensionId] = args[2]
                                    set_exsh.ext2ShChanged()
                                    set_exsh.checkForChanges()
                                }

                                set_exsh.extensionIdIndexForDetectingNewShortcut = -1

                            }
                        }

                    }

                    Component.onCompleted: {
                        deleg.checkDuplicate(deleg.extShortcut)
                    }

                }

            }

        }

    ]

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered:
            console.warn(">>>", set_exsh.ext2Sh)
    }

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        var ext2shChanged = false
        for(var i in allExtensions) {
            if(ext2Sh[allExtensions[i]] !== PQCExtensionsHandler.getShortcutForExtension(allExtensions[i])) {
                ext2shChanged = true
                break
            }
        }

        var refE = PQCExtensionsHandler.getExtensions().sort()
        var refD = PQCExtensionsHandler.getDisabledExtensions().sort()

        PQCConstants.settingsManagerSettingChanged = (!PQF.areTwoListsEqual(extensionsEnabled, refE) ||
                                                      !PQF.areTwoListsEqual(extensionsDisabled, refD) ||
                                                      ext2shChanged)

    }

    function load() {

        settingsLoaded = false

        // prepare global shortcut map
        var allext = PQCExtensionsHandler.getExtensionsEnabledAndDisabld()
        for(var i in allext)
            ext2Sh[allext[i]] = PQCExtensionsHandler.getShortcutForExtension(allext[i])
        ext2ShChanged()

        // set without property bindings (i.e., here and not above where they are declared)
        allExtensions = allext
        extensionsEnabled = PQCExtensionsHandler.getExtensions()
        extensionsDisabled = PQCExtensionsHandler.getDisabledExtensions()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        for(var i in allExtensions)
            PQCExtensionsHandler.addShortcut(allExtensions[i], ext2Sh[allExtensions[i]])

        PQCConstants.settingsManagerSettingChanged = false

    }

}
