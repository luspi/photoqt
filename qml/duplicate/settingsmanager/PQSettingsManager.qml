/**************************************************************************
 * *                                                                      **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

PQTemplate {

    id: settingsmanager_top

    title: qsTranslate("settingsmanager", "Settings Manager")
    elementId: "SettingsManager"
    letMeHandleClosing: true

    property list<string> flickableNotInteractiveFor: []

    SystemPalette { id: pqtPalette }

    Connections {
        target: button1
        function onClicked() {
            PQCNotify.settingsmanagerSendCommand("applychanges", []);
        }
    }
    Connections {
        target: button2
        function onClicked() {
            PQCNotify.settingsmanagerSendCommand("loadcurrent", []);
        }
    }
    Connections {
        target: button3
        function onClicked() {
            settingsmanager_top.hide()
        }
    }

    Component.onCompleted: {
        button1.text = qsTranslate("settingsmanager", "Apply changes")
        button1.enabled = Qt.binding(function() { return PQCConstants.settingsManagerSettingChanged })

        button2.text = qsTranslate("settingsmanager", "Revert changes")
        button2.visible = true
        button2.enabled = Qt.binding(function() { return button1.enabled })

        button3.visible = true
        button3.text = button1.genericStringClose
        button3.font.weight = PQCLook.fontWeightNormal
    }

    onShowing: {
        PQCNotify.settingsmanagerSendCommand("loadcurrent", [])
    }

    onHiding: {
        button3.clicked()
    }

    bottomLeftContent: [
        Row {
            y: (bottomLeft.height-height)/2
            spacing: 10
            Item {
                width: 1
                height: 1
            }
            PQCheckBox {
                text: qsTranslate("settingsmanager", "auto-save")
                font.pointSize: PQCLook.fontSizeS
                checked: PQCSettings.generalAutoSaveSettings
                onCheckedChanged: {
                    PQCSettings.generalAutoSaveSettings = checked
                }
            }
            PQCheckBox {
                text: qsTranslate("settingsmanager", "compact")
                font.pointSize: PQCLook.fontSizeS
                checked: PQCSettings.generalCompactSettings
                onCheckedChanged: {
                    PQCSettings.generalCompactSettings = checked
                }
            }
        }
    ]

    content: [

        Row {

            id: splitview

            width: settingsmanager_top.width
            height: settingsmanager_top.availableHeight

            PQSettingsTabs {

                id: maintabbar

                width: Math.max(Math.min(settingsmanager_top.width*0.25, 350), 200)
                height: parent.height

                onCurrentIndexChanged:
                    currentComponentsChanged()

                onCurrentComponentsChanged: {

                    var currentId = currentComponents[currentIndex]

                    if(currentIndex === 0) {

                             if(currentId === "ovin") settings_loader.sourceComponent = int_ovin
                        else if(currentId === "wimo") settings_loader.sourceComponent = int_wimo
                        else if(currentId === "wibu") settings_loader.sourceComponent = int_wibu
                        else if(currentId === "acco") settings_loader.sourceComponent = int_acco
                        else if(currentId === "fowe") settings_loader.sourceComponent = int_fowe
                        else if(currentId === "back") settings_loader.sourceComponent = int_back
                        else if(currentId === "noti") settings_loader.sourceComponent = int_noti
                        else if(currentId === "popo") settings_loader.sourceComponent = int_popo
                        else if(currentId === "edge") settings_loader.sourceComponent = int_edge
                        else if(currentId === "come") settings_loader.sourceComponent = int_come
                        else if(currentId === "stin") settings_loader.sourceComponent = int_stin

                    } else if(currentIndex === 1) {

                             if(currentId === "look") settings_loader.sourceComponent = imv_look
                        else if(currentId === "inte") settings_loader.sourceComponent = imv_inte
                        else if(currentId === "fili") settings_loader.sourceComponent = imv_fili
                        else if(currentId === "impr") settings_loader.sourceComponent = imv_impr
                        else if(currentId === "capr") settings_loader.sourceComponent = imv_capr
                        else if(currentId === "meta") settings_loader.sourceComponent = imv_meta
                        else if(currentId === "shon") settings_loader.sourceComponent = imv_shon
                        else if(currentId === "fata") settings_loader.sourceComponent = imv_fata

                    } else if(currentIndex === 2) {

                             if(currentId === "imag") settings_loader.sourceComponent = thb_imag
                        else if(currentId === "info") settings_loader.sourceComponent = thb_info
                        else if(currentId === "bar" ) settings_loader.sourceComponent = thb_bar
                        else if(currentId === "mana") settings_loader.sourceComponent = thb_mana

                    } else if(currentIndex === 3) {

                             if(currentId === "list") settings_loader.sourceComponent = fty_list
                        else if(currentId === "anim") settings_loader.sourceComponent = fty_anim
                        else if(currentId === "raw" ) settings_loader.sourceComponent = fty_raw
                        else if(currentId === "arch") settings_loader.sourceComponent = fty_arch
                        else if(currentId === "docu") settings_loader.sourceComponent = fty_docu
                        else if(currentId === "vide") settings_loader.sourceComponent = fty_vide
                        else if(currentId === "moti") settings_loader.sourceComponent = fty_moti
                        else if(currentId === "sphe") settings_loader.sourceComponent = fty_sphe

                    } else if(currentIndex === 4) {

                             if(currentId === "list") settings_loader.sourceComponent = sho_list
                        else if(currentId === "exsh") settings_loader.sourceComponent = sho_exsh
                        else if(currentId === "dush") settings_loader.sourceComponent = sho_dush
                        else if(currentId === "exmo") settings_loader.sourceComponent = sho_exmo
                        else if(currentId === "exke") settings_loader.sourceComponent = sho_exke

                    } else if(currentIndex === 5) {

                             if(currentId === "seha") settings_loader.sourceComponent = man_seha
                        else if(currentId === "tric") settings_loader.sourceComponent = man_tric
                        else if(currentId === "mana") settings_loader.sourceComponent = man_mana

                    } else if(currentIndex === 7) {

                             if(currentId === "fidi") settings_loader.sourceComponent = oth_fidi
                        else if(currentId === "slsh") settings_loader.sourceComponent = oth_slsh

                   }

                }

                Component { id: int_ovin; PQSettingsInterfaceOverallInterface { availableHeight: flickable.height } }
                Component { id: int_wimo; PQSettingsInterfaceWindowMode { availableHeight: flickable.height } }
                Component { id: int_wibu; PQSettingsInterfaceWindowButtons { availableHeight: flickable.height } }
                Component { id: int_acco; PQSettingsInterfaceAccentColor { availableHeight: flickable.height } }
                Component { id: int_fowe; PQSettingsInterfaceFontWeight { availableHeight: flickable.height } }
                Component { id: int_back; PQSettingsInterfaceBackground { availableHeight: flickable.height } }
                Component { id: int_noti; PQSettingsInterfaceNotification { availableHeight: flickable.height } }
                Component { id: int_popo; PQSettingsInterfacePopout { availableHeight: flickable.height } }
                Component { id: int_edge; PQSettingsInterfaceEdges { availableHeight: flickable.height } }
                Component { id: int_come; PQSettingsInterfaceContextMenu { availableHeight: flickable.height } }
                Component { id: int_stin; PQSettingsInterfaceStatusInfo { availableHeight: flickable.height } }

                Component { id: imv_look; PQSettingsImageViewLook { availableHeight: flickable.height } }
                Component { id: imv_inte; PQSettingsImageViewInteraction { availableHeight: flickable.height } }
                Component { id: imv_fili; PQSettingsImageViewFileList { availableHeight: flickable.height } }
                Component { id: imv_impr; PQSettingsImageViewImageProcessing { availableHeight: flickable.height } }
                Component { id: imv_capr; PQSettingsImageViewCache { availableHeight: flickable.height } }
                Component { id: imv_meta; PQSettingsImageViewMetadata { availableHeight: flickable.height } }
                Component { id: imv_shon; PQSettingsImageViewShareOnline { availableHeight: flickable.height } }
                Component { id: imv_fata; PQSettingsImageViewFaceTags { availableHeight: flickable.height } }

                Component { id: thb_imag; PQSettingsThumbnailsImage { availableHeight: flickable.height } }
                Component { id: thb_info; PQSettingsThumbnailsInfo { availableHeight: flickable.height } }
                Component { id: thb_bar ; PQSettingsThumbnailsBar { availableHeight: flickable.height } }
                Component { id: thb_mana; PQSettingsThumbnailsManage { availableHeight: flickable.height } }

                Component { id: fty_list; PQSettingsFiletypesList { availableHeight: flickable.height } }
                Component { id: fty_anim; PQSettingsFiletypesAnimated { availableHeight: flickable.height } }
                Component { id: fty_raw ; PQSettingsFiletypesRAW { availableHeight: flickable.height } }
                Component { id: fty_arch; PQSettingsFiletypesArchives { availableHeight: flickable.height } }
                Component { id: fty_docu; PQSettingsFiletypesDocuments { availableHeight: flickable.height } }
                Component { id: fty_vide; PQSettingsFiletypesVideos { availableHeight: flickable.height } }
                Component { id: fty_moti; PQSettingsFiletypesMotion { availableHeight: flickable.height } }
                Component { id: fty_sphe; PQSettingsFiletypesSpheres { availableHeight: flickable.height } }

                Component { id: sho_list; PQSettingsShortcutsList { availableHeight: flickable.height } }
                Component { id: sho_exsh; PQSettingsShortcutsExternalShortcuts { availableHeight: flickable.height } }
                Component { id: sho_dush; PQSettingsShortcutsDuplicateShortcuts { availableHeight: flickable.height } }
                Component { id: sho_exmo; PQSettingsShortcutsExtraMouse { availableHeight: flickable.height } }
                Component { id: sho_exke; PQSettingsShortcutsExtraKeys { availableHeight: flickable.height } }

                Component { id: man_seha; PQSettingsManageSession { availableHeight: flickable.height } }
                Component { id: man_tric; PQSettingsManageTrayIcon { availableHeight: flickable.height } }
                Component { id: man_mana; PQSettingsManageManage { availableHeight: flickable.height } }

                Component { id: oth_fidi; PQSettingsOtherFileDialog { availableHeight: flickable.height } }
                Component { id: oth_slsh; PQSettingsOtherSlideshow { availableHeight: flickable.height } }

            }

            Rectangle {
                width: 1
                height: parent.height
                color: pqtPalette.text
                opacity: 0.2
            }

            Flickable {

                id: flickable

                y: 10
                width: splitview.width-maintabbar.width-2
                height: parent.height-10

                contentHeight: settings_loader.height

                ScrollBar.vertical: PQVerticalScrollBar {}

                interactive: maintabbar.makeFlickableInteractive

                Loader {
                    id: settings_loader
                    x: 10
                    width: parent.width-20
                }

            }

        }

    ]

    PQSettingsShortcutsDetectNew {
        id: detectNew
        parent: settingsmanager_top.parent.parent
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(settingsmanager_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(detectNew.visible)
                        return

                    if(param[0] === Qt.Key_Escape) {

                        button3.clicked()

                    } else if(param[0] === Qt.Key_S && param[1] === Qt.ControlModifier) {

                        PQCNotify.settingsmanagerSendCommand("applychanges", []);

                    }

                }

            }

        }

    }

}
