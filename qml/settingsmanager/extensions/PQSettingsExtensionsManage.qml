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

    property int currentExpandedSetting: -1

    onExtensionsDisabledChanged: checkForChanges()
    onExtensionsEnabledChanged: checkForChanges()

    SystemPalette { id: pqtPalette }

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Enabled extensions")

            helptext: qsTranslate("settingsmanager",  "PhotoQt's capabilities can be increased with various extensions. Here you can find a list of extensions currently known to PhotoQt and you can choose which one should be enabled. Some extensions come with additional settings accessible through the button on the far right.")

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

                    property bool isVerified: PQCScriptsConfig.isDebugBuild() ?
                                                  false :
                                                  PQCExtensionsHandler.verifyExtension(extBaseDir, extensionId)
                    property bool isDebugBuild: PQCScriptsConfig.isDebugBuild()

                    property bool hasSettings: PQCExtensionsHandler.getHasSettings(extensionId)

                    property string tooltipText: "<h2>" + deleg.extName + "</h2>
                                                 <b>" + qsTranslate("settingsmanager", "Version") + ":</b> " + extVersion + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Author") + ":</b> " + extAuthor + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Contact") + ":</b> " + extContact + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Website:") + "</b> " + extWebsite + "<br><br>
                                                 <b>" + qsTranslate("settingsmanager", "Loaded from") + ":</b><br>" + extBaseDir

                    width: col.width
                    height: (set_maex.currentExpandedSetting==index ? 300 : 40)
                    color: pqtPalette.alternateBase
                    clip: true

                    Behavior on height { NumberAnimation { duration: 200 } }

                    Item {

                        width: parent.width
                        height: 40

                        PQMouseArea {
                            id: entrymouse
                            width: parent.width
                            height: 40
                            hoverEnabled: true
                            cursorShape: deleg.hasSettings ? Qt.PointingHandCursor : Qt.ArrowCursor
                            text: (deleg.hasSettings ? "<i>Click here to show extension specific settings.</i>" : "") + deleg.tooltipText
                            onClicked: {
                                if(!deleg.hasSettings) return
                                if(set_maex.currentExpandedSetting !== deleg.index)
                                    set_maex.currentExpandedSetting = deleg.index
                                else
                                    set_maex.currentExpandedSetting = -1
                            }
                        }

                        PQCheckBox {
                            id: check
                            x: 5
                            y: (parent.height-height)/2
                            text: deleg.extName
                            tooltip: deleg.tooltipText
                            checked: set_maex.extensionsEnabled.indexOf(deleg.extensionId)>-1
                            property bool ignoreNextChange: false
                            onCheckedChanged: {

                                if(!set_maex.settingsLoaded) return

                                if(ignoreNextChange) {
                                    ignoreNextChange = false
                                    return
                                }

                                if(checked) {
                                    set_maex.extensionsEnabled.push(deleg.extensionId)
                                    set_maex.extensionsDisabled = set_maex.extensionsDisabled.filter(item => item!==deleg.extensionId)
                                } else {
                                    set_maex.extensionsDisabled.push(deleg.extensionId)
                                    set_maex.extensionsEnabled = set_maex.extensionsEnabled.filter(item => item!==deleg.extensionId)
                                }
                                set_maex.extensionsEnabled.sort()
                                set_maex.extensionsDisabled.sort()

                                // remove property binding to avoid warnings about binding loops
                                ignoreNextChange = true
                                checked = checked
                            }

                        }

                        PQMouseArea {
                            width: check.width+10
                            height: parent.height
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: "<i>Click here to enable/disable extension.</i>" + deleg.tooltipText
                            onClicked: {
                                check.checked = !check.checked
                            }
                        }

                        Image {
                            id: verified
                            visible: !deleg.isDebugBuild
                            x: check.x+check.width+5
                            y: (parent.height-height)/2
                            width: visible ? check.height*0.75 : 0
                            height: visible ? check.height*0.75 : 0
                            source: "image://svg/:/other/verified_" + (deleg.isVerified ? "yes" : "no") + ".svg"
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            id: desc
                            x: verified.x+verified.width+10
                            y: (parent.height-height)/2
                            width: deleg.width-verified.width-setupButton.width-check.width-30
                            enabled: false
                            text: deleg.extDesc
                            elide: Text.ElideRight
                        }

                        Image {
                            id: setupButton
                            x: (parent.width-width-10)
                            width: 40
                            height: 40
                            enabled: PQCExtensionsHandler.getHasSettings(deleg.extensionId)
                            opacity: enabled ? 1 : 0.1
                            source: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
                        }

                    }

                    Rectangle {
                        y: 40
                        width: parent.width
                        height: 1
                        color: PQCLook.baseBorder
                        visible: deleg.height>41
                    }

                    Loader {
                        anchors.fill: parent
                        anchors.topMargin: 40
                        active: deleg.height>41
                        source: "file:/"+PQCExtensionsHandler.getExtensionLocation(deleg.extensionId) + "/qml/PQ"+deleg.extensionId+"Settings.qml"
                    }

                }

            }

        },

        /***************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Verification")

            helptext: qsTranslate("settingsmanager", "Loading and executing arbitrary code always has to be treated with some caution. PhotoQt by default verifies any extension to make sure it is an official extension that has not been modified. If you want to use a custom or unofficial extension, you can disable this check here.")

        },

        PQText {
            x: -set_maex.indentWidth
            text: qsTranslate("settingsmanager", "Please be cautious about using code from unknown sources and make sure you can trust the origin of your extension.")
            font.weight: PQCLook.fontWeightBold
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        },

        PQCheckBox {
            id: verifyCheck
            text: qsTranslate("settingsmanager", "Enforce extension verification")
            enabled: !PQCScriptsConfig.isDebugBuild()
            onCheckedChanged: set_maex.checkForChanges()
        },

        PQText {
            x: -set_maex.indentWidth
            // this string does not need to be translated, normal users will never see it
            text: "Note: Debug builds never enforce verification of extensions."
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        },

        /***************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Install extension")

            helptext: qsTranslate("settingsmanager", "PhotoQt can be extended with new extensions. Please be careful with where you get any extension and make sure that you trust its origin before installing any extension.")

        },

        PQButton {
            text: qsTranslate("settingsmanager", "Select and install extension")
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
            text: qsTranslate("settingsmanager", "Result:") + " " + (code==2 ?
                      qsTranslate("settingsmanager", "Extension with this id exists already.") :
                      (code == 1 ?
                           qsTranslate("settingsmanager", "Extension successfully installed.") :
                           (code == 0 ?
                                qsTranslate("settingsmanager", "Extension failed to install.") :
                                (code == -1 ?
                                     qsTranslate("settingsmanager", "Extension was not installed.") :
                                     (code == -2 ?
                                          qsTranslate("settingsmanager", "Extensions support not available.") :
                                          (code == -3 ?
                                               qsTranslate("settingsmanager", "Extension was installed but not all files could be extracted. It might not work properly.") :
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
                                                      !PQF.areTwoListsEqual(extensionsDisabled, refD) ||
                                                      verifyCheck.hasChanged())

    }

    function load() {

        settingsLoaded = false

        set_maex.currentExpandedSetting = -1

        // set without property bindings (i.e., here and not above where they are declared)
        allExtensions = PQCExtensionsHandler.getExtensionsEnabledAndDisabld()
        extensionsEnabled = PQCExtensionsHandler.getExtensions()
        extensionsDisabled = PQCExtensionsHandler.getDisabledExtensions()

        if(PQCScriptsConfig.isDebugBuild())
            verifyCheck.checked = false
        else
            verifyCheck.loadAndSetDefault(PQCSettings.generalExtensionsEnforeVerification)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCExtensionsHandler.setDisabledExtensions(extensionsDisabled)
        PQCExtensionsHandler.setEnabledExtensions(extensionsEnabled)
        PQCSettings.generalExtensionsEnabled = extensionsEnabled

        if(!PQCScriptsConfig.isDebugBuild())
            PQCSettings.generalExtensionsEnforeVerification = verifyCheck.checked

        PQCConstants.settingsManagerSettingChanged = false

    }

}
