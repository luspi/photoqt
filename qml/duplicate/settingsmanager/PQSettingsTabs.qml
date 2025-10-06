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

Item {

    id: tab_top

    width: 300
    height: parent.height

    SystemPalette { id: pqtPalette }

    property int currentIndex: 0
    property list<string> currentComponents: ["", "", "", "", "", "", ""]

    property list<string> _flickableNotInteractiveFor: ["4_list", "4_exsh", "4_dush"]

    property bool makeFlickableInteractive: _flickableNotInteractiveFor.indexOf(currentIndex.toString()+"_"+currentComponents[currentIndex])===-1

    Column {

        width: parent.width

        PQTabButton {
            id: maintab1
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===0
            text: qsTranslate("settingsmanager", "Interface")
            onClicked:
                tab_top.currentIndex = 0
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===0 ? subtabbar_interface.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 0

            Column {

                id: subtabbar_interface

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[0] = entries[0][0]
                }

                property list<var> entries: PQCSettings.generalInterfaceVariant==="modern" ? entries_modern : entries_integrated
                property list<var> entries_modern: [
                    ["ovin", qsTranslate("settingsmanager", "Overall Interface")],
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
                    ["ovin", qsTranslate("settingsmanager", "Overall Interface")],
                    ["fowe", qsTranslate("settingsmanager", "Font weight")],
                    ["back", qsTranslate("settingsmanager", "Background")],
                    ["noti", qsTranslate("settingsmanager", "Notification")],
                    ["come", qsTranslate("settingsmanager", "Context Menu")],
                    ["stin", qsTranslate("settingsmanager", "Status Info")]
                ]

                Repeater {

                    model: subtabbar_interface.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_interface.tabheight = height
                        isCurrentTab: tab_top.currentComponents[0]===subtabbar_interface.entries[index][0]
                        text: subtabbar_interface.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[0] = subtabbar_interface.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_interface.entries[index].length === 3 && subtabbar_interface.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===1
            text: qsTranslate("settingsmanager", "Image view")
            lineAbove: tab_top.currentIndex===0
            onClicked:
                tab_top.currentIndex = 1
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===1 ? subtabbar_imageview.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 1

            Column {

                id: subtabbar_imageview

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[1] = entries[0][0]
                }

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

                Repeater {

                    model: subtabbar_imageview.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_imageview.tabheight = height
                        isCurrentTab: tab_top.currentComponents[1]===subtabbar_imageview.entries[index][0]
                        text: subtabbar_imageview.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[1] = subtabbar_imageview.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_imageview.entries[index].length === 3 && subtabbar_imageview.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===2
            text: qsTranslate("settingsmanager", "Thumbnails")
            lineAbove: tab_top.currentIndex===1
            onClicked:
                tab_top.currentIndex = 2
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===2 ? subtabbar_thumbnails.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 2

            Column {

                id: subtabbar_thumbnails

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[2] = entries[0][0]
                }

                property list<var> entries: [
                    ["imag", qsTranslate("settingsmanager", "Image")],
                    ["info", qsTranslate("settingsmanager", "Information")],
                    ["bar" , qsTranslate("settingsmanager", "Thumbnail bar")],
                    ["mana", qsTranslate("settingsmanager", "Manage")]
                ]

                Repeater {

                    model: subtabbar_thumbnails.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_thumbnails.tabheight = height
                        isCurrentTab: tab_top.currentComponents[2]===subtabbar_thumbnails.entries[index][0]
                        text: subtabbar_thumbnails.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[2] = subtabbar_thumbnails.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_thumbnails.entries[index].length === 3 && subtabbar_thumbnails.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===3
            text: qsTranslate("settingsmanager", "File types")
            lineAbove: tab_top.currentIndex===2
            onClicked:
                tab_top.currentIndex = 3
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===3 ? subtabbar_filetypes.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 3

            Column {

                id: subtabbar_filetypes

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[3] = entries[0][0]
                }

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

                Repeater {

                    model: subtabbar_filetypes.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_filetypes.tabheight = height
                        isCurrentTab: tab_top.currentComponents[3]===subtabbar_filetypes.entries[index][0]
                        text: subtabbar_filetypes.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[3] = subtabbar_filetypes.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
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

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===4
            text: qsTranslate("settingsmanager", "Keyboard & Mouse")
            lineAbove: tab_top.currentIndex===3
            onClicked:
                tab_top.currentIndex = 4
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===4 ? subtabbar_mousekeys.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 4

            Column {

                id: subtabbar_mousekeys

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[4] = entries[0][0]
                }

                property list<var> entries: [
                    ["list", qsTranslate("settingsmanager", "Shortcuts")],
                    ["exsh", qsTranslate("settingsmanager", "External Shortcuts")],
                    ["dush", qsTranslate("settingsmanager", "Duplicate Shortcuts"), "---"],
                    ["exmo", qsTranslate("settingsmanager", "Extra mouse settings")],
                    ["exke", qsTranslate("settingsmanager", "Extra keyboard settings")]
                ]

                Repeater {

                    model: subtabbar_mousekeys.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_mousekeys.tabheight = height
                        isCurrentTab: tab_top.currentComponents[4]===subtabbar_mousekeys.entries[index][0]
                        text: subtabbar_mousekeys.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[4] = subtabbar_mousekeys.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_mousekeys.entries[index].length === 3 && subtabbar_mousekeys.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===5
            text: qsTranslate("settingsmanager", "Manage")
            lineAbove: tab_top.currentIndex===4
            onClicked:
                tab_top.currentIndex = 5
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===5 ? subtabbar_manage.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 5

            Column {

                id: subtabbar_manage

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[5] = entries[0][0]
                }

                property list<var> entries: [
                    ["seha", qsTranslate("settingsmanager", "Session handling")],
                    ["tric", qsTranslate("settingsmanager", "Tray icon")],
                    ["mana", qsTranslate("settingsmanager", "Manage")]
                ]

                Repeater {

                    model: subtabbar_manage.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_manage.tabheight = height
                        isCurrentTab: tab_top.currentComponents[5]===subtabbar_manage.entries[index][0]
                        text: subtabbar_manage.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[5] = subtabbar_manage.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_manage.entries[index].length === 3 && subtabbar_manage.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===6
            text: qsTranslate("settingsmanager", "Extensions")
            lineAbove: tab_top.currentIndex===5
            onClicked:
                tab_top.currentIndex = 6
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===6 ? subtabbar_extensions.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 6

            Column {

                id: subtabbar_extensions

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[6] = entries[0][0]
                }

                property list<var> entries: [
                    ["ext1", qsTranslate("settingsmanager", "Extension 1")],
                ]

                Repeater {

                    model: subtabbar_extensions.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_extensions.tabheight = height
                        isCurrentTab: tab_top.currentComponents[6]===subtabbar_extensions.entries[index][0]
                        text: subtabbar_extensions.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[6] = subtabbar_extensions.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_extensions.entries[index].length === 3 && subtabbar_extensions.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

        PQTabButton {
            width: parent.width
            settingsManagerMainTab: true
            isCurrentTab: tab_top.currentIndex===6
            text: qsTranslate("settingsmanager", "Other")
            lineAbove: tab_top.currentIndex===6
            onClicked:
                tab_top.currentIndex = 7
        }

        Item {

            width: parent.width
            height: tab_top.currentIndex===7 ? subtabbar_other.height : 0
            Behavior on height { NumberAnimation { duration: 200 } }
            clip: true
            visible: height>1
            enabled: tab_top.currentIndex === 7

            Column {

                id: subtabbar_other

                x: 20
                width: parent.width-x

                property int tabheight: 40

                // This is needed so that when the variant is switched we do not run into warnings before a reboot happens
                Component.onCompleted: {
                    entries = entries
                    tab_top.currentComponents[7] = entries[0][0]
                }

                property list<var> entries: [
                    ["fidi", qsTranslate("settingsmanager", "File dialog")],
                    ["slsh", qsTranslate("settingsmanager", "Slideshow")]
                ]

                Repeater {

                    model: subtabbar_other.entries.length

                    PQTabButton {
                        required property int index
                        width: parent.width
                        onHeightChanged:
                            subtabbar_other.tabheight = height
                        isCurrentTab: tab_top.currentComponents[7]===subtabbar_other.entries[index][0]
                        text: subtabbar_other.entries[index][1]
                        onClicked: {
                            tab_top.currentComponents[7] = subtabbar_other.entries[index][0]
                            tab_top.currentComponentsChanged()
                        }
                        Rectangle {
                            y: parent.height-height
                            width: parent.width
                            height: 1
                            color: pqtPalette.text
                            visible: subtabbar_other.entries[index].length === 3 && subtabbar_other.entries[index][2] === "---"
                            opacity: 0.1
                        }
                    }

                }

            }

        }

        /**********************************************/

    }

}
