/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import PQCNotify

import "../../../elements"

// required top level properties for all settings:
//
// 1) property bool settingChanged
// 2) function applyChanges()
// 3) function revertChanges()

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

    property bool settingChanged: false
    property bool settingsLoaded: false

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
        "left": ["", "thumbnails", "metadata"],
        "right": ["mainmenu"],
        "bottom": ["", "thumbnails"]
    }

    Column {

        id: contcol

        spacing: 10

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Edges")

            helptext: qsTranslate("settingsmanager", "Moving the mouse cursor to the edges of the application window can trigger the visibility of some things, like the main menu, thumbnails, or metadata. Here you can choose what is triggered by which window edge. Note that the main menu is fixed to the right window edge and cannot be moved or disabled.")

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
                                font.weight: current["top"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: topmouse.hovered ? PQCLook.textColorActive : PQCLook.textColor
                                text: labels[current["top"]]
                            }

                            PQMouseArea {
                                id: topmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: changeEdge("top")
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
                                font.weight: current["left"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: leftmouse.hovered ? PQCLook.textColorActive : PQCLook.textColor
                                text: labels[current["left"]]
                            }
                            PQMouseArea {
                                id: leftmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: changeEdge("left")
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
                            color: PQCLook.baseColorHighlight
                            Behavior on color { ColorAnimation { duration: 200 } }
                            enabled: false
                            PQText {
                                anchors.centerIn: parent
                                rotation: 90
                                font.weight: current["right"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: PQCLook.textColorHighlight
                                text: labels[current["right"]]
                            }
                            PQMouseArea {
                                id: rightmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "The right edge action cannot be changed")
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
                                font.weight: current["bottom"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                                color: botmouse.hovered ? PQCLook.textColorActive : PQCLook.textColor
                                text: labels[current["bottom"]]
                            }
                            PQMouseArea {
                                id: botmouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: The action here is a screen edge action
                                text: qsTranslate("settingsmanager", "Click to change action")
                                onClicked: changeEdge("bottom")
                            }
                        }

                        Item {
                            width: 50
                            height: 50
                        }

                    }

                }

            ]

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQSetting {

            //: Settings title
            title: qsTranslate("settingsmanager", "Sensitivity")

            helptext: qsTranslate("settingsmanager", "The edge actions defined above are triggered whenever the mouse cursor gets close to the screen edge. The sensitivity determines how close to the edge the mouse cursor needs to be for this to happen. A value that is too sensitive might cause the edge action to sometimes be triggered accidentally.")

            content: [

                Row {

                    spacing: 10

                    PQText {
                        y: (parent.height-height)/2
                        text: qsTranslate("settingsmanager", "Sensitivity") + ":"
                    }

                    Rectangle {

                        width: sensitivity.width
                        height: sensitivity.height
                        color: PQCLook.baseColorHighlight

                        PQSpinBox {
                            id: sensitivity
                            from: 1
                            to: 20
                            width: 120
                            onValueChanged: checkDefault()
                            visible: !butsensitivity_val.visible && enabled
                            Component.onDestruction:
                                PQCNotify.spinBoxPassKeyEvents = false
                        }

                        PQText {
                            id: butsensitivity_val
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: sensitivity.value + " px"
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                //: Tooltip, used as in: Click to edit this value
                                text: qsTranslate("settingsmanager", "Click to edit")
                                onClicked: {
                                    PQCNotify.spinBoxPassKeyEvents = true
                                    butsensitivity_val.visible = false
                                }
                            }
                        }

                    }

                    PQButton {
                        id: acceptbut
                        //: Written on button, the value is whatever was entered in a spin box
                        text: qsTranslate("settingsmanager", "Accept value")
                        font.pointSize: PQCLook.fontSize
                        font.weight: PQCLook.fontWeightNormal
                        height: 35
                        visible: !butsensitivity_val.visible && enabled
                        onClicked: {
                            PQCNotify.spinBoxPassKeyEvents = false
                            butsensitivity_val.visible = true
                        }
                    }

                }
            ]

        }

    }

    PQMenu {
        id: menu
        property string edge: "top"
        Repeater {
            id: menurep
            model: actions[menu.edge].length
            PQMenuItem {
                checkable: true
                property string act: actions[menu.edge][index]
                text: labels[act]
                checked: current[menu.edge] === act
                onTriggered: {
                    current[menu.edge] = act
                    makeSureUnique(menu.edge, act)
                    currentChanged()
                }
            }
        }
    }

    function makeSureUnique(edge, act) {

        var ed = ["top", "left", "right", "bottom"]
        for(var i in ed) {
            if(ed[i] !== edge) {
                if(current[ed[i]] === act)
                    current[ed[i]] = ""
            }
        }

    }

    function changeEdge(edge) {

        menu.edge = edge
        menu.popup()

    }

    Component.onCompleted:
        load()

    function checkDefault() {

        if(!settingsLoaded) return
        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        if(current["top"] !== PQCSettings.interfaceEdgeTopAction ||
                current["left"] !== PQCSettings.interfaceEdgeLeftAction ||
                current["right"] !== PQCSettings.interfaceEdgeRightAction ||
                current["bottom"] !== PQCSettings.interfaceEdgeBottomAction ||
                sensitivity.hasChanged()) {
            settingChanged = true
            return
        }

        settingChanged = false

    }

    function load() {

        current["top"] = PQCSettings.interfaceEdgeTopAction
        current["left"] = PQCSettings.interfaceEdgeLeftAction
        current["right"] = PQCSettings.interfaceEdgeRightAction
        current["bottom"] = PQCSettings.interfaceEdgeBottomAction
        currentChanged()

        sensitivity.loadAndSetDefault(PQCSettings.interfaceHotEdgeSize)
        butsensitivity_val.visible = true

        PQCNotify.spinBoxPassKeyEvents = false

        settingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceEdgeTopAction = current["top"]
        PQCSettings.interfaceEdgeLeftAction = current["left"]
        PQCSettings.interfaceEdgeRightAction = "mainmenu"
        PQCSettings.interfaceEdgeBottomAction = current["bottom"]

        PQCSettings.interfaceHotEdgeSize = sensitivity.value
        sensitivity.saveDefault()

        settingChanged = false

    }

    function revertChanges() {
        load()
    }

}
