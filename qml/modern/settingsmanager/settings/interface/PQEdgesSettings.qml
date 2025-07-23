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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt.Modern

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) property bool catchEscape
// 3) function applyChanges()
// 4) function revertChanges()
// 5) function handleEscape()

// settings in this file:
// - interfaceHotEdgeSize
// - interfaceEdgeBottomAction
// - interfaceEdgeLeftAction
// - interfaceEdgeRightAction
// - interfaceEdgeTopAction

Flickable {

    id: setting_top

    anchors.fill: parent
    anchors.margins: 10

    contentHeight: contcol.height

    ScrollBar.vertical: PQVerticalScrollBar {}

    PQScrollManager { flickable: setting_top }

    property bool settingChanged: false
    property bool settingsLoaded: false

    property bool catchEscape: themenu.visible || sensitivity.editMode || sensitivity.contextMenuOpen

    property var current: {
        "top": "",
        "left": "",
        "right": "",
        "bottom": "",
    }
    onCurrentChanged:
        checkDefault()

    property var labels: {
        //: Used as descriptor for a screen edge action
        "" : qsTranslate("settingsmanager", "No action"),
        //: Used as descriptor for a screen edge action
        "thumbnails" : qsTranslate("settingsmanager", "Thumbnails"),
        //: Used as descriptor for a screen edge action
        "mainmenu" : qsTranslate("settingsmanager", "Main menu"),
        //: Used as descriptor for a screen edge action
        "metadata" : qsTranslate("settingsmanager", "Metadata")
    }

    property var actions: {
        "top": ["", "thumbnails"],
        "left": ["", "thumbnails", "metadata", "mainmenu"],
        "right": ["", "thumbnails", "metadata", "mainmenu"],
        "bottom": ["", "thumbnails"]
    }

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            id: set_edges

            //: Settings title
            title: qsTranslate("settingsmanager", "Edges")

            helptext: qsTranslate("settingsmanager", "Moving the mouse cursor to the edges of the application window can trigger the visibility of some things, like the main menu, thumbnails, or metadata. Here you can choose what is triggered by which window edge. Note that if the main menu is completely disabled, then the settings manager can still be accessed by shortcut or through the context menu.")

            content: [

                Column {

                    Row {

                        Item {
                            width: 50
                            height: 50
                        }

                        Rectangle {
                            id: topedge
                            width: 200
                            height: 50
                            color: topmouse.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight 
                            Behavior on color { ColorAnimation { duration: 200 } }
                            PQText {
                                anchors.centerIn: parent
                                font.weight: setting_top.current["top"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: PQCLook.textColor 
                                text: setting_top.labels[setting_top.current["top"]]
                            }

                            PQMouseArea {
                                id: topmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: setting_top.changeEdge("top")
                            }
                        }

                        Item {
                            width: 50
                            height: 50
                        }

                    }

                    Row {

                        Rectangle {
                            id: leftedge
                            width: 50
                            height: 200
                            color: leftmouse.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight 
                            Behavior on color { ColorAnimation { duration: 200 } }
                            PQText {
                                anchors.centerIn: parent
                                rotation: -90
                                font.weight: setting_top.current["left"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: PQCLook.textColor 
                                text: setting_top.labels[setting_top.current["left"]]
                            }
                            PQMouseArea {
                                id: leftmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: setting_top.changeEdge("left")
                            }
                        }

                        Item {
                            width: 200
                            height: 200
                        }

                        Rectangle {
                            id: rightedge
                            width: 50
                            height: 200
                            color: rightmouse.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight 
                            Behavior on color { ColorAnimation { duration: 200 } }
                            PQText {
                                anchors.centerIn: parent
                                rotation: 90
                                font.weight: setting_top.current["right"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: PQCLook.textColor 
                                text: setting_top.labels[setting_top.current["right"]]
                            }
                            PQMouseArea {
                                id: rightmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: setting_top.changeEdge("right")
                            }
                        }

                    }

                    Row {

                        Item {
                            width: 50
                            height: 50
                        }

                        Rectangle {
                            id: botedge
                            width: 200
                            height: 50
                            color: botmouse.hovered ? PQCLook.baseColorActive : PQCLook.baseColorHighlight 
                            Behavior on color { ColorAnimation { duration: 200 } }
                            PQText {
                                anchors.centerIn: parent
                                font.weight: setting_top.current["bottom"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: PQCLook.textColor 
                                text: setting_top.labels[setting_top.current["bottom"]]
                            }
                            PQMouseArea {
                                id: botmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: setting_top.changeEdge("bottom")
                            }
                        }

                        Item {
                            width: 50
                            height: 50
                        }

                    }

                }

            ]

            onResetToDefaults: {
                current["top"] = PQCSettings.getDefaultForInterfaceEdgeTopAction()
                current["left"] = PQCSettings.getDefaultForInterfaceEdgeLeftAction()
                current["right"] = PQCSettings.getDefaultForInterfaceEdgeRightAction()
                current["bottom"] = PQCSettings.getDefaultForInterfaceEdgeBottomAction()
                currentChanged()
            }

            function handleEscape() {
                themenu.close()
            }

            function hasChanged() {
                return (current["top"] !== PQCSettings.interfaceEdgeTopAction ||
                        current["left"] !== PQCSettings.interfaceEdgeLeftAction ||
                        current["right"] !== PQCSettings.interfaceEdgeRightAction ||
                        current["bottom"] !== PQCSettings.interfaceEdgeBottomAction)
            }

            function load() {
                current["top"] = PQCSettings.interfaceEdgeTopAction 
                current["left"] = PQCSettings.interfaceEdgeLeftAction
                current["right"] = PQCSettings.interfaceEdgeRightAction
                current["bottom"] = PQCSettings.interfaceEdgeBottomAction
                currentChanged()
            }

            function applyChanges() {
                PQCSettings.interfaceEdgeTopAction = current["top"] 
                PQCSettings.interfaceEdgeLeftAction = current["left"]
                PQCSettings.interfaceEdgeRightAction = current["right"]
                PQCSettings.interfaceEdgeBottomAction = current["bottom"]
            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            id: set_sens

            //: Settings title
            title: qsTranslate("settingsmanager", "Sensitivity")

            helptext: qsTranslate("settingsmanager", "The edge actions defined above are triggered whenever the mouse cursor gets close to the screen edge. The sensitivity determines how close to the edge the mouse cursor needs to be for this to happen. A value that is too sensitive might cause the edge action to sometimes be triggered accidentally.")

            content: [

                PQSliderSpinBox {
                    id: sensitivity
                    width: set_sens.rightcol
                    minval: 5
                    maxval: 100
                    suffix: " px"
                    onValueChanged:
                        setting_top.checkDefault()
                }

            ]

            onResetToDefaults: {
                sensitivity.setValue(PQCSettings.getDefaultForInterfaceHotEdgeSize()*5)
            }

            function handleEscape() {
                sensitivity.acceptValue()
                sensitivity.closeContextMenus()
            }

            function hasChanged() {
                return sensitivity.hasChanged()
            }

            function load() {
                sensitivity.loadAndSetDefault(PQCSettings.interfaceHotEdgeSize*5)
            }

            function applyChanges() {
                PQCSettings.interfaceHotEdgeSize = Math.round(sensitivity.value/5)
                sensitivity.saveDefault()
            }

        }

    }

    property string menuedge: "top"

    PQMenu {
        id: themenu
        Repeater {
            id: menurep
            property list<string> curdat: setting_top.actions[setting_top.menuedge]
            model: curdat.length
            PQMenuItem {
                required property int modelData
                checkable: true
                property string act: modelData < menurep.curdat.length ? menurep.curdat[modelData] : ""
                text: setting_top.labels[act]
                checked: setting_top.current[setting_top.menuedge] === act
                checkableLikeRadioButton: true
                onCheckedChanged: {
                    if(checked && setting_top.current[setting_top.menuedge] !== act) {
                        setting_top.current[setting_top.menuedge] = act
                        setting_top.makeSureUnique(setting_top.menuedge, act)
                        setting_top.currentChanged()
                    }
                    checked = Qt.binding(function() { return current[setting_top.menuedge] === act; })
                    themenu.close()
                }
            }
        }
    }

    function makeSureUnique(edge: string, act: string) {

        var ed = ["top", "left", "right", "bottom"]
        for(var i in ed) {
            if(ed[i] !== edge) {
                if(current[ed[i]] === act)
                    current[ed[i]] = ""
            }
        }

    }

    function changeEdge(edge: string) {

        setting_top.menuedge = edge
        themenu.popup()

    }

    Component.onCompleted:
        load()

    Component.onDestruction:
        themenu.close()

    function handleEscape() {
        set_edges.handleEscape()
        set_sens.handleEscape()
    }

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) { 
            applyChanges()
            return
        }

        settingChanged = (set_edges.hasChanged()||set_sens.hasChanged())

    }

    function load() {

        set_edges.load()
        set_sens.load()

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        set_edges.applyChanges()
        set_sens.applyChanges()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
