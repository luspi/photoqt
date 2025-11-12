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

    id: set_maex

    property list<string> allExtensions
    property list<string> extensionsEnabled
    property list<string> extensionsDisabled

    onExtensionsDisabledChanged: checkForChanges()
    onExtensionsEnabledChanged: checkForChanges()

    SystemPalette { id: pqtPalette }

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Enabled extensions")

            helptext: qsTranslate("settingsmanager",  "PhotoQt's capabilities can be increased with various extensions. Here you can find a list of extensions currently known to PhotoQt and you can choose which one should be enabled.")

            showLineAbove: false

        },

        Column {

            id: col

            width: parent.width

            spacing: 10

            Repeater {
                model: set_maex.allExtensions.length

                Rectangle {

                    id: deleg

                    required property int index
                    property string extensionId: set_maex.allExtensions[index]

                    opacity: check.checked ? 1 : (entrymouse.containsMouse ? 0.8 : 0.6)
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    property string extVersion: PQCExtensionsHandler.getExtensionVersion(extensionId)
                    property string extName: PQCExtensionsHandler.getExtensionName(extensionId)
                    property string extDesc: PQCExtensionsHandler.getExtensionDescription(extensionId)
                    property string extAuthor: PQCExtensionsHandler.getExtensionAuthor(extensionId)
                    property string extContact: PQCExtensionsHandler.getExtensionContact(extensionId)
                    property string extWebsite: PQCExtensionsHandler.getExtensionWebsite(extensionId)
                    property string extBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)

                    width: col.width
                    height: 40
                    color: pqtPalette.alternateBase

                    PQCheckBox {
                        id: check
                        x: 5
                        y: (parent.height-height)/2
                        text: deleg.extName
                        tooltip: deleg.extDesc
                        checked: set_maex.extensionsEnabled.indexOf(deleg.extensionId)>-1
                    }

                    PQText {
                        id: desc
                        x: check.x+check.width+10
                        y: (parent.height-height)/2
                        width: deleg.width-check.width-author.width-15
                        enabled: false
                        text: deleg.extDesc
                        elide: Text.ElideRight
                    }

                    PQMouseArea {
                        id: entrymouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(check.checked) {
                                set_maex.extensionsEnabled = set_maex.extensionsEnabled.filter(item => item!==deleg.extensionId)
                                set_maex.extensionsDisabled.push(deleg.extensionId)
                            } else {
                                set_maex.extensionsDisabled = set_maex.extensionsDisabled.filter(item => item!==deleg.extensionId)
                                set_maex.extensionsEnabled.push(deleg.extensionId)
                            }
                            set_maex.extensionsEnabled.sort()
                            set_maex.extensionsDisabled.sort()
                        }
                    }

                    PQButtonIcon {
                        id: author
                        x: deleg.width-width-5
                        y: (parent.height-height)/2
                        source: "image://svg/:/" + PQCLook.iconShade + "/about.svg"
                        tooltip: "<h2>" + deleg.extName + "</h2><b>Version:</b> " + deleg.extVersion + "<br><b>Author:</b> " + deleg.extAuthor + "<br><b>Contact:</b> " + deleg.extContact + "<br><b>Website:</b> " + deleg.extWebsite + "<br><br><b>Loaded from:</b><br>" + deleg.extBaseDir
                        tooltipDelay: 0
                    }

                }

            }

        },

        /***************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Install extension")

            helptext: qsTranslate("settingsmanager", "PhotoQt can be extended with new extensions. Please be careful with where you get any extension and make sure that you trust the source before installing any extension.")

        },

        PQButton {
            text: "Select and install extension"
            onClicked: {
                extStatus.visible = false
                var f = PQCScriptsFilesPaths.openFileFromDialog("Install", PQCScriptsFilesPaths.getHomeDir(), "pqe")
                if(PQCScriptsFilesPaths.doesItExist(f)) {
                    extStatus.code = PQCExtensionsHandler.installExtension(f)
                    extStatus.visible = true
                }
            }
        },

        PQTextL {
            id: extStatus
            visible: false
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            property int code: 0
            text: "Result: " + (code==2 ?
                      "Extension with this id exists already." :
                      (code == 1 ?
                           "Extension successfully installed." :
                           (code == 0 ?
                                "Extension failed to install." :
                                (code == -1 ?
                                     "Extension was not installed." :
                                     (code == -2 ?
                                          "Extensions support not available." :
                                          (code == -3 ?
                                               "Extension was installed but not all files could be extracted.\nIt might not work properly." :
                                               ("Unknown status code: "+code)))))))
        }

    ]

    function handleEscape() {}

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        var refE = PQCExtensionsHandler.getExtensions().sort()
        var refD = PQCExtensionsHandler.getDisabledExtensions().sort()

        PQCConstants.settingsManagerSettingChanged = (!PQF.areTwoListsEqual(extensionsEnabled, refE) ||
                                                      !PQF.areTwoListsEqual(extensionsDisabled, refD))

    }

    function load() {

        settingsLoaded = false

        // set without property bindings (i.e., here and not above where they are declared)
        allExtensions = PQCExtensionsHandler.getExtensionsEnabledAndDisabld()
        extensionsEnabled = PQCExtensionsHandler.getExtensions()
        extensionsDisabled = PQCExtensionsHandler.getDisabledExtensions()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCExtensionsHandler.setDisabledExtensions(extensionsDisabled)
        PQCExtensionsHandler.setEnabledExtensions(extensionsEnabled)

        PQCConstants.settingsManagerSettingChanged = false

    }

}
