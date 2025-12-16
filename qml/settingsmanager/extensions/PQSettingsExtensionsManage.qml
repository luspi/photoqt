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
    property list<string> extensionsFailed

    property int currentExpandedSetting: -1

    onExtensionsDisabledChanged: checkForChanges()
    onExtensionsEnabledChanged: checkForChanges()

    signal loadCheckedStatus()

    property list<string> extensionTrustRevoked: []

    content: [

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Available extensions")

            helptext: qsTranslate("settingsmanager", "PhotoQt's capabilities can be increased with various extensions. Here you can find a list of extensions currently known to PhotoQt and you can choose which one should be enabled. Some extensions come with additional settings that can be accessed by clicking on their entry. The trust status of an unverified extension that was trusted in the past can also be revoked here.")

            showLineAbove: false

        },

        Item {

            width: parent.width
            height: noext.height+20
            visible: set_maex.allExtensions.length===0

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

            Repeater {
                model: set_maex.allExtensions.length

                Rectangle {

                    id: extension_setting

                    required property int index
                    property string extensionId: set_maex.allExtensions[index]

                    opacity: check.checked ? 1 : (entrymouse.containsMouse ? 0.8 : 0.6)
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                    property string extVersion: PQCExtensionsHandler.getExtensionVersion(extensionId)
                    property string extName: PQCExtensionsHandler.getExtensionName(extensionId)
                    property string extDesc: PQCExtensionsHandler.getExtensionDescription(extensionId)
                    property string extAuthor: PQCExtensionsHandler.getExtensionAuthor(extensionId)
                    property string extContact: PQCExtensionsHandler.getExtensionContact(extensionId)
                    property string extWebsite: PQCExtensionsHandler.getExtensionWebsite(extensionId)
                    property string extBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)

                    property bool isVerified: PQCScriptsConfig.isDebugBuild() ?
                                                  true :
                                                  PQCExtensionsHandler.verifyExtension(extBaseDir, "")
                    property bool isDebugBuild: PQCScriptsConfig.isDebugBuild()

                    property bool hasSettings: PQCExtensionsHandler.getHasSettings(extensionId)

                    property string tooltipText: "<h2>" + extension_setting.extName + "</h2>
                                                 <b>" + qsTranslate("settingsmanager", "Version") + ":</b> " + extVersion + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Author") + ":</b> " + extAuthor + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Contact") + ":</b> " + extContact + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Website:") + "</b> " + extWebsite + "<br><br>
                                                 <b>" + qsTranslate("settingsmanager", "Loaded from") + ":</b><br>" + extBaseDir

                    width: col.width
                    height: (set_maex.currentExpandedSetting==index ? 300 : 40)
                    color: palette.alternateBase
                    clip: true

                    Behavior on height { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                    Component.onCompleted: {
                        if(PQCConstants.settingsManagerStartWithExtensionOpen === extensionId) {
                            set_maex.currentExpandedSetting = index
                            PQCConstants.settingsManagerStartWithExtensionOpen = ""
                        }
                    }

                    Item {

                        width: parent.width
                        height: 40

                        enabled: extension_setting.isVerified || PQCSettings.generalExtensionsAllowUntrusted.indexOf(extension_setting.extensionId) > -1

                        PQMouseArea {
                            id: entrymouse
                            width: parent.width
                            height: 40
                            hoverEnabled: true
                            cursorShape: extension_setting.hasSettings ? Qt.PointingHandCursor : Qt.ArrowCursor
                            text: (extension_setting.hasSettings ? "<i>" + qsTranslate("settingsmanager", "Click here to show extension specific settings.") + "</i>" : "") + extension_setting.tooltipText
                            onClicked: {
                                if(!extension_setting.hasSettings || !check.checked) {
                                    check.checked = !check.checked
                                    return
                                }
                                if(set_maex.currentExpandedSetting !== extension_setting.index)
                                    set_maex.currentExpandedSetting = extension_setting.index
                                else
                                    set_maex.currentExpandedSetting = -1
                            }
                        }

                        PQCheckBox {
                            id: check
                            x: 5
                            y: (parent.height-height)/2
                            text: extension_setting.extName
                            tooltip: extension_setting.tooltipText
                            onCheckedChanged: {

                                if(!set_maex.settingsLoaded) return

                                if(checked) {
                                    set_maex.extensionsEnabled.push(extension_setting.extensionId)
                                    set_maex.extensionsDisabled = set_maex.extensionsDisabled.filter(item => item!==extension_setting.extensionId)
                                } else {
                                    set_maex.extensionsDisabled.push(extension_setting.extensionId)
                                    set_maex.extensionsEnabled = set_maex.extensionsEnabled.filter(item => item!==extension_setting.extensionId)
                                    if(set_maex.currentExpandedSetting === extension_setting.index)
                                        set_maex.currentExpandedSetting = -1
                                }
                                set_maex.extensionsEnabled.sort()
                                set_maex.extensionsDisabled.sort()

                            }

                            Connections {
                                target: set_maex
                                function onLoadCheckedStatus() {
                                    check.loadAndSetDefault(set_maex.extensionsEnabled.indexOf(extension_setting.extensionId)>-1)
                                }
                            }

                        }

                        PQMouseArea {
                            width: check.width+10
                            height: parent.height
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: "<i>" + qsTranslate("settingsmanager", "Click here to enable/disable extension.") + "</i>" + extension_setting.tooltipText
                            onClicked: {
                                check.checked = !check.checked
                            }
                        }

                        Image {
                            id: verified
                            visible: !extension_setting.isDebugBuild
                            x: check.x+check.width+5
                            y: (parent.height-height)/2
                            width: visible ? check.height*0.75 : 0
                            height: visible ? check.height*0.75 : 0
                            source: "image://svg/:/other/verified_" + (extension_setting.isVerified ? "yes" : "no") + ".svg"
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            id: desc
                            x: verified.x+verified.width+10
                            y: (parent.height-height)/2
                            width: extension_setting.width-verified.width-setupButton.width-(revokeTrust.visible ? revokeTrust.width : 0)-check.width-40
                            opacity: 0.8
                            text: extension_setting.extDesc
                            elide: Text.ElideRight
                        }

                        PQButton {
                            id: revokeTrust
                            x: desc.x+desc.width
                            enabled: extensionTrustRevoked.indexOf(extension_setting.extensionId) === -1
                            visible: PQCSettings.generalExtensionsAllowUntrusted.indexOf(extension_setting.extensionId)>-1 ||
                                     extensionTrustRevoked.indexOf(extension_setting.extensionId) > -1
                            height: 40
                            //: Trust here refers to trusting an unverified extension to run.
                            text: qsTranslate("settingsmanager", "Revoke trust")
                            smallerVersion: true
                            fontWeight: PQCLook.fontWeightNormal
                            onClicked: {
                                set_maex.extensionTrustRevoked.push(extension_setting.extensionId)
                                PQCSettings.generalExtensionsAllowUntrusted = PQCSettings.generalExtensionsAllowUntrusted.filter(item => item !== extension_setting.extensionId)
                                PQCExtensionsHandler.disableExtension(extension_setting.extensionId)
                                check.checked = false
                            }
                        }

                        Image {
                            id: setupButton
                            x: (parent.width-width-10)
                            width: 40
                            height: 40
                            enabled: PQCExtensionsHandler.getHasSettings(extension_setting.extensionId)
                            opacity: enabled ? 1 : 0.1
                            source: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
                        }

                    }

                    Rectangle {
                        y: 40
                        width: parent.width
                        height: 1
                        color: PQCLook.baseBorder
                        visible: extension_setting.height>41
                    }

                    Loader {
                        anchors.fill: parent
                        anchors.topMargin: 40
                        active: extension_setting.height>41
                        source: "file:/"+PQCExtensionsHandler.getExtensionLocation(extension_setting.extensionId) + "/qml/"+PQCExtensionsHandler.getExtensionNameId(extension_setting.extensionId)+"Settings.qml"
                    }

                }

            }

        },

        /***************************************/

        PQSettingSubtitle {

            visible: set_maex.extensionsFailed.length>0

            //: A settings title
            title: qsTranslate("settingsmanager", "Unavailable extensions")

            helptext: qsTranslate("settingsmanager", "These extensions were found in the relevant locations but they failed their verification check. If you know the source of an extension you can manually force-enable any one of them. Note that you need to restart PhotoQt for an untrusted but allowed extension to be loaded.")

        },

        Column {

            id: col_failed

            width: parent.width

            visible: set_maex.extensionsFailed.length>0

            spacing: 10

            Repeater {
                model: set_maex.extensionsFailed.length

                Rectangle {

                    id: extensionfailed_setting

                    required property int index
                    property string extensionId: set_maex.extensionsFailed[index]

                    property string extVersion: PQCExtensionsHandler.getExtensionVersion(extensionId)
                    property string extName: PQCExtensionsHandler.getExtensionName(extensionId)
                    property string extDesc: PQCExtensionsHandler.getExtensionDescription(extensionId)
                    property string extAuthor: PQCExtensionsHandler.getExtensionAuthor(extensionId)
                    property string extContact: PQCExtensionsHandler.getExtensionContact(extensionId)
                    property string extWebsite: PQCExtensionsHandler.getExtensionWebsite(extensionId)
                    property string extBaseDir: PQCExtensionsHandler.getExtensionLocation(extensionId)

                    property string tooltipText: "<h2>" + extensionfailed_setting.extName + "</h2>
                                                 <b>" + qsTranslate("settingsmanager", "Version") + ":</b> " + extVersion + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Author") + ":</b> " + extAuthor + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Contact") + ":</b> " + extContact + "<br>
                                                 <b>" + qsTranslate("settingsmanager", "Website:") + "</b> " + extWebsite + "<br><br>
                                                 <b>" + qsTranslate("settingsmanager", "Loaded from") + ":</b><br>" + extBaseDir

                    width: col_failed.width
                    height: 40
                    color: palette.alternateBase
                    clip: true

                    Item {

                        width: parent.width
                        height: 40

                        PQText {
                            id: nametxt
                            x: 5
                            y: (parent.height-height)/2
                            text: extensionfailed_setting.extName
                        }

                        PQMouseArea {
                            width: nametxt.width+10
                            height: parent.height
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: extensionfailed_setting.tooltipText
                        }

                        Image {
                            id: verified_failed
                            visible: !extensionfailed_setting.isDebugBuild
                            x: nametxt.x+nametxt.width+5
                            y: (parent.height-height)/2
                            width: visible ? nametxt.height*0.75 : 0
                            height: visible ? nametxt.height*0.75 : 0
                            source: "image://svg/:/other/verified_no.svg"
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            id: desc_failed
                            x: verified_failed.x+verified_failed.width+10
                            y: (parent.height-height)/2
                            width: extensionfailed_setting.width-verified_failed.width-trustButton.width-nametxt.width-30
                            opacity: 0.8
                            text: extensionfailed_setting.extDesc
                            elide: Text.ElideRight
                        }

                        PQButton {
                            id: trustButton
                            x: (parent.width-width)
                            height: 40
                            smallerVersion: true
                            fontWeight: PQCLook.fontWeightNormal
                            enabled: PQCSettings.generalExtensionsAllowUntrusted.indexOf(extensionfailed_setting.extensionId)===-1
                            text: qsTranslate("settingsmanager", "Trust this extension")
                            onClicked: {
                                if(PQCScriptsConfig.askForConfirmation(qsTranslate("settingsmanager", "Trust extension?"), qsTranslate("settingsmanager", "Name:") + " " + extensionfailed_setting.extName, qsTranslate("settingsmanager", "Are you sure you want to enable this extension? This will take effect the next time you start PhotoQt."))) {
                                    if(PQCSettings.generalExtensionsAllowUntrusted.indexOf(extensionfailed_setting.extensionId) === -1)
                                        PQCSettings.generalExtensionsAllowUntrusted.push(extensionfailed_setting.extensionId)
                                    if(PQCSettings.generalExtensionsEnabled.indexOf(extensionfailed_setting.extensionId) > -1)
                                        PQCSettings.generalExtensionsEnabled = PQCSettings.generalExtensionsEnabled.filter((item, index) => item !== extensionfailed_setting.extensionId)
                                }
                            }
                        }

                    }

                }

            }

        },

        /***************************************/

        PQSettingSubtitle {

            //: A settings title
            title: qsTranslate("settingsmanager", "Install extension")

            helptext: qsTranslate("settingsmanager", "PhotoQt can be extended with new extensions. Please be careful with where you get any extension and make sure that you trust its origin before installing anything.")

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
                                                      !PQF.areTwoListsEqual(extensionsDisabled, refD))

    }

    function load() {

        settingsLoaded = false

        set_maex.currentExpandedSetting = -1

        // set without property bindings (i.e., here and not above where they are declared)
        allExtensions = PQCExtensionsHandler.getExtensionsEnabledAndDisabld()
        extensionsEnabled = PQCExtensionsHandler.getExtensions()
        extensionsDisabled = PQCExtensionsHandler.getDisabledExtensions()
        extensionsFailed = PQCExtensionsHandler.getFailedExtensions()

        set_maex.loadCheckedStatus()

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        var enabledUnique = extensionsEnabled.filter((item, index) => extensionsEnabled.indexOf(item) === index && extensionTrustRevoked.indexOf(item) === -1).sort()
        var disabledUnique = extensionsDisabled.filter((item, index) => extensionsDisabled.indexOf(item) === index || extensionTrustRevoked.indexOf(item) > -1).sort()

        PQCExtensionsHandler.setDisabledExtensions(disabledUnique)
        PQCExtensionsHandler.setEnabledExtensions(enabledUnique)
        PQCSettings.generalExtensionsEnabled = enabledUnique

        PQCConstants.settingsManagerSettingChanged = false

    }

}
