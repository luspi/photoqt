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
        PQCNotify.resetActiveFocus()
        // HANDLE HIDING INCLUDING CALLING CLOSE SIGNAL
    }

    bottomLeftContent: [
        Row {
            y: (bottomLeft.height-height)/2
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

        SplitView {

            id: splitview

            width: settingsmanager_top.width
            height: settingsmanager_top.height

            // Show larger handle with triple dash
            handle: Rectangle {
                implicitWidth: 8
                implicitHeight: 8
                color: pqtPalette.text
                opacity: SplitHandle.hovered ? 0.5 : 0.2
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    y: (splitview.height-height)/2
                    width: splitview.implicitWidth
                    height: splitview.implicitHeight
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/handle.svg"
                }

            }

            PQTabBar {

                id: maintabbar

                SplitView.minimumWidth: 150
                SplitView.preferredWidth: 250
                height: parent.height
                implicitWidth: width

                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===0
                    text: qsTranslate("settingsmanager", "Interface")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===1
                    text: qsTranslate("settingsmanager", "Image view")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===2
                    text: qsTranslate("settingsmanager", "Thumbnails")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===3
                    text: qsTranslate("settingsmanager", "File types")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===4
                    text: qsTranslate("settingsmanager", "Keyboard & Mouse")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===5
                    text: qsTranslate("settingsmanager", "Manage")
                }
                PQTabButton {
                    width: maintabbar.width
                    implicitHeight: maintabbar.height/maintabbar.count
                    font.weight: PQCLook.fontWeightBold
                    isCurrentTab: maintabbar.currentIndex===6
                    text: qsTranslate("settingsmanager", "Other")
                }
            }

            StackLayout {

                id: stacklayout

                SplitView.minimumWidth: 150
                SplitView.preferredWidth: 400

                height: parent.height
                currentIndex: maintabbar.currentIndex

                onCurrentIndexChanged: {
                    if(currentIndex === 0) {
                        subtabbar_interface.currentIndex = 0
                        subtabbar_interface.currentIndexChanged()
                        subtabbar_interface.currentIdChanged()
                    } else if(currentIndex === 1) {
                        subtabbar_imageview.currentIndex = 0
                        subtabbar_imageview.currentIndexChanged()
                        subtabbar_imageview.currentIdChanged()
                    } else if(currentIndex === 2) {
                        subtabbar_thumbnails.currentIndex = 0
                        subtabbar_thumbnails.currentIndexChanged()
                        subtabbar_thumbnails.currentIdChanged()
                    } else if(currentIndex === 3) {
                        subtabbar_filetypes.currentIndex = 0
                        subtabbar_filetypes.currentIndexChanged()
                        subtabbar_filetypes.currentIdChanged()
                    } else if(currentIndex === 4) {
                        // subtabbar_mousekeys.currentIndex = 0
                        // subtabbar_mousekeys.currentIndexChanged()
                        // subtabbar_mousekeys.currentIdChanged()
                    } else if(currentIndex === 5) {
                        subtabbar_manage.currentIndex = 0
                        subtabbar_manage.currentIndexChanged()
                        subtabbar_manage.currentIdChanged()
                    }
                }

                PQTabBar {

                    id: subtabbar_interface

                    width: stacklayout.width
                    height: parent.height
                    property string currentId: ""

                    property list<var> entries: PQCSettings.generalInterfaceVariant==="modern" ? entries_modern : entries_integrated
                    property list<var> entries_modern: [
                        ["lang", qsTranslate("settingsmanager", "Language")],
                        ["wimo", qsTranslate("settingsmanager", "Window mode")],
                        ["wibu", qsTranslate("settingsmanager", "Window buttons")],
                        ["acco", qsTranslate("settingsmanager", "Accent color")],
                        ["fowe", qsTranslate("settingsmanager", "Font weight")],
                        ["back", qsTranslate("settingsmanager", "Background")],
                        ["noti", qsTranslate("settingsmanager", "Notification")],
                        ["popo", qsTranslate("settingsmanager", "Popout")],
                        ["edge", qsTranslate("settingsmanager", "Edges")],
                        ["come", qsTranslate("settingsmanager", "Context Menu")],
                        ["stin", qsTranslate("settingsmanager", "Status Info")]
                    ]
                    property list<var> entries_integrated: [
                        ["lang", qsTranslate("settingsmanager", "Language")],
                        ["fowe", qsTranslate("settingsmanager", "Font weight")],
                        ["back", qsTranslate("settingsmanager", "Background")],
                        ["noti", qsTranslate("settingsmanager", "Notification")],
                        ["come", qsTranslate("settingsmanager", "Context Menu")],
                        ["stin", qsTranslate("settingsmanager", "Status Info")]
                    ]

                    Component { id: int_lang; PQSettingsInterfaceLanguage {} }
                    Component { id: int_wimo; PQSettingsInterfaceWindowMode {} }
                    Component { id: int_wibu; PQSettingsInterfaceWindowButtons {} }
                    Component { id: int_acco; PQSettingsInterfaceAccentColor {} }
                    Component { id: int_fowe; PQSettingsInterfaceFontWeight {} }
                    Component { id: int_back; PQSettingsInterfaceBackground {} }
                    Component { id: int_noti; PQSettingsInterfaceNotification {} }
                    Component { id: int_popo; PQSettingsInterfacePopout {} }
                    Component { id: int_edge; PQSettingsInterfaceEdges {} }
                    Component { id: int_come; PQSettingsInterfaceContextMenu {} }
                    Component { id: int_stin; PQSettingsInterfaceStatusInfo {} }

                    onCurrentIndexChanged:
                        subtabbar_interface.currentId = entries[currentIndex][0]

                    onCurrentIdChanged: {
                             if(currentId === "lang") settings_loader.sourceComponent = int_lang
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
                    }


                    Repeater {

                        model: subtabbar_interface.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_interface.currentIndex===index
                            text: subtabbar_interface.entries[index][1]
                        }

                    }
                }

                PQTabBar {

                    id: subtabbar_imageview

                    width: parent.width
                    height: parent.height
                    property string currentId: ""

                    property list<var> entries: [
                        ["look", qsTranslate("settingsmanager", "Look")],
                        ["inte", qsTranslate("settingsmanager", "Interaction")],
                        ["fili", qsTranslate("settingsmanager", "File list")],
                        ["impr", qsTranslate("settingsmanager", "Image processing")],
                        ["capr", qsTranslate("settingsmanager", "Cache and Preloading")],
                        ["meta", qsTranslate("settingsmanager", "Metadata")],
                        ["fata", qsTranslate("settingsmanager", "Face tags")],
                        ["shon", qsTranslate("settingsmanager", "Share online")]
                    ]

                    Component { id: imv_look; PQSettingsImageViewLook {} }
                    Component { id: imv_inte; PQSettingsImageViewInteraction {} }
                    Component { id: imv_fili; PQSettingsImageViewFileList {} }
                    Component { id: imv_impr; PQSettingsImageViewImageProcessing {} }
                    Component { id: imv_capr; PQSettingsImageViewCache {} }
                    Component { id: imv_meta; PQSettingsImageViewMetadata {} }
                    Component { id: imv_shon; PQSettingsImageViewShareOnline {} }
                    Component { id: imv_fata; PQSettingsImageViewFaceTags {} }

                    onCurrentIndexChanged:
                        subtabbar_imageview.currentId = entries[currentIndex][0]

                    onCurrentIdChanged: {
                             if(currentId === "look") settings_loader.sourceComponent = imv_look
                        else if(currentId === "inte") settings_loader.sourceComponent = imv_inte
                        else if(currentId === "fili") settings_loader.sourceComponent = imv_fili
                        else if(currentId === "impr") settings_loader.sourceComponent = imv_impr
                        else if(currentId === "capr") settings_loader.sourceComponent = imv_capr
                        else if(currentId === "meta") settings_loader.sourceComponent = imv_meta
                        else if(currentId === "shon") settings_loader.sourceComponent = imv_shon
                        else if(currentId === "fata") settings_loader.sourceComponent = imv_fata
                    }

                    Repeater {

                        model: subtabbar_imageview.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_imageview.currentIndex===index
                            text: subtabbar_imageview.entries[index][1]
                        }

                    }

                }

                PQTabBar {

                    id: subtabbar_thumbnails

                    width: parent.width
                    height: parent.height
                    property string currentId: ""

                    property list<var> entries: [
                        ["imag", qsTranslate("settingsmanager", "Image")],
                        ["info", qsTranslate("settingsmanager", "Information")],
                        ["bar" , qsTranslate("settingsmanager", "Bar")],
                        ["mana", qsTranslate("settingsmanager", "Manage")]
                    ]

                    Component { id: thb_imag; PQSettingsThumbnailsImage {} }
                    Component { id: thb_info; PQSettingsThumbnailsInfo {} }
                    Component { id: thb_bar ; PQSettingsThumbnailsBar {} }
                    Component { id: thb_mana; PQSettingsThumbnailsManage {} }

                    onCurrentIndexChanged:
                        subtabbar_thumbnails.currentId = entries[currentIndex][0]

                    onCurrentIdChanged: {
                             if(currentId === "imag") settings_loader.sourceComponent = thb_imag
                        else if(currentId === "info") settings_loader.sourceComponent = thb_info
                        else if(currentId === "bar" ) settings_loader.sourceComponent = thb_bar
                        else if(currentId === "mana") settings_loader.sourceComponent = thb_mana
                    }

                    Repeater {

                        model: subtabbar_thumbnails.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_thumbnails.currentIndex===index
                            text: subtabbar_thumbnails.entries[index][1]
                        }

                    }

                }

                PQTabBar {

                    id: subtabbar_filetypes

                    width: parent.width
                    height: parent.height
                    property string currentId: ""

                    property list<var> entries: [
                        ["list", qsTranslate("settingsmanager", "File types"), "---"],
                        ["anim", qsTranslate("settingsmanager", "Animated images")],
                        ["raw" , qsTranslate("settingsmanager", "RAW images")],
                        ["arch", qsTranslate("settingsmanager", "Archives")],
                        ["docu", qsTranslate("settingsmanager", "Documents")],
                        ["vide", qsTranslate("settingsmanager", "Videos")],
                        ["moti", qsTranslate("settingsmanager", "Motion/Live photos")],
                        ["sphe", qsTranslate("settingsmanager", "Photo spheres")]
                    ]

                    Component { id: fty_list; PQSettingsFiletypesList { availableHeight: flickable.height; addBlankSpaceBottom: false } }
                    Component { id: fty_anim; PQSettingsFiletypesAnimated {} }
                    Component { id: fty_raw ; PQSettingsFiletypesRAW {} }
                    Component { id: fty_arch; PQSettingsFiletypesArchives {} }
                    Component { id: fty_docu; PQSettingsFiletypesDocuments {} }
                    Component { id: fty_vide; PQSettingsFiletypesVideos {} }
                    Component { id: fty_moti; PQSettingsFiletypesMotion {} }
                    Component { id: fty_sphe; PQSettingsFiletypesSpheres {} }

                    onCurrentIndexChanged:
                        subtabbar_filetypes.currentId = entries[currentIndex][0]

                    onCurrentIdChanged: {
                             if(currentId === "list") settings_loader.sourceComponent = fty_list
                        else if(currentId === "anim") settings_loader.sourceComponent = fty_anim
                        else if(currentId === "raw" ) settings_loader.sourceComponent = fty_raw
                        else if(currentId === "arch") settings_loader.sourceComponent = fty_arch
                        else if(currentId === "docu") settings_loader.sourceComponent = fty_docu
                        else if(currentId === "vide") settings_loader.sourceComponent = fty_vide
                        else if(currentId === "moti") settings_loader.sourceComponent = fty_moti
                        else if(currentId === "sphe") settings_loader.sourceComponent = fty_sphe
                    }

                    Repeater {

                        model: subtabbar_filetypes.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_filetypes.currentIndex===index
                            text: subtabbar_filetypes.entries[index][1]
                            Rectangle {
                                y: parent.height-height
                                width: parent.width
                                height: 1
                                color: pqtPalette.text
                                visible: subtabbar_filetypes.entries[index].length === 3 && subtabbar_filetypes.entries[index][2] === "---"
                                opacity: 0.1
                            }
                        }

                    }

                }

                PQTabBar {

                    id: subtabbar_mousekeys

                    width: parent.width
                    height: parent.height

                    property list<string> entries: [
                        qsTranslate("settingsmanager", "Shortcuts"),
                        qsTranslate("settingsmanager", "Mouse buttons"),
                        qsTranslate("settingsmanager", "Mouse wheel"),
                        qsTranslate("settingsmanager", "Hide cursor"),
                        qsTranslate("settingsmanager", "Escape key handling")
                    ]

                    Repeater {

                        model: subtabbar_mousekeys.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_mousekeys.currentIndex===index
                            text: subtabbar_mousekeys.entries[index]
                        }

                    }

                }

                PQTabBar {

                    id: subtabbar_manage

                    width: parent.width
                    height: parent.height
                    property string currentId: ""

                    property list<var> entries: [
                        ["seha", qsTranslate("settingsmanager", "Session handling")],
                        ["tric", qsTranslate("settingsmanager", "Tray icon")],
                        ["mana", qsTranslate("settingsmanager", "Manage")]
                    ]

                    Component { id: man_seha; PQSettingsManageSession {} }
                    Component { id: man_tric; PQSettingsManageTrayIcon {} }
                    Component { id: man_mana; PQSettingsManageManage {} }

                    onCurrentIndexChanged:
                        subtabbar_manage.currentId = entries[currentIndex][0]

                    onCurrentIdChanged: {
                             if(currentId === "seha") settings_loader.sourceComponent = man_seha
                        else if(currentId === "tric") settings_loader.sourceComponent = man_tric
                        else if(currentId === "mana") settings_loader.sourceComponent = man_mana
                    }

                    Repeater {

                        model: subtabbar_manage.entries.length

                        PQTabButton {
                            required property int index
                            width: parent.width
                            isCurrentTab: subtabbar_manage.currentIndex===index
                            text: subtabbar_manage.entries[index][1]
                        }

                    }

                }

            }

            Flickable {

                id: flickable

                SplitView.minimumWidth: 300
                SplitView.fillWidth: true

                y: 10
                height: parent.height-10

                contentHeight: settings_loader.height

                ScrollBar.vertical: PQVerticalScrollBar {}

                Loader {
                    id: settings_loader
                    x: 10
                    width: parent.width-20
                }

            }

        }

    ]

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(settingsmanager_top.opacity > 0) {

                if(what === "keyEvent") {

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
