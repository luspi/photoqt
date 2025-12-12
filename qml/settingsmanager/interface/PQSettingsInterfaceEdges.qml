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

import QtQuick
import PhotoQt

PQSetting {

    id: set_edge

    property var current: {
        "top": "",
        "left": "",
        "right": "",
        "bottom": "",
    }
    onCurrentChanged:
        checkForChanges()

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

    content: [

        PQSettingSubtitle {

            showLineAbove: false

            //: A settings title
            title: qsTranslate("settingsmanager", "Edges")

            helptext: qsTranslate("settingsmanager", "Moving the mouse cursor to the edges of the application window can trigger the visibility of some things, like the main menu, thumbnails, or metadata. Here you can choose what is triggered by which window edge. Note that if the main menu is completely disabled, then the settings manager can still be accessed by shortcut or through the context menu.")

        },

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
                    color: "transparent"
                    PQHighlightMarker {
                        visible: topmouse.hovered||(themenu.opened&&menuedge==="top")
                    }
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    PQText {
                        anchors.centerIn: parent
                        font.weight: set_edge.current["top"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                        color: palette.text
                        text: set_edge.labels[set_edge.current["top"]]
                    }

                    PQMouseArea {
                        id: topmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The action here is a screen edge action
                        text: qsTranslate("settingsmanager", "Click to change action")
                        onClicked: set_edge.changeEdge("top")
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
                    color: "transparent"
                    PQHighlightMarker {
                        visible: leftmouse.hovered||(themenu.opened&&menuedge==="left")
                    }
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    PQText {
                        anchors.centerIn: parent
                        rotation: -90
                        font.weight: set_edge.current["left"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                        color: palette.text
                        text: set_edge.labels[set_edge.current["left"]]
                    }
                    PQMouseArea {
                        id: leftmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The action here is a screen edge action
                        text: qsTranslate("settingsmanager", "Click to change action")
                        onClicked: set_edge.changeEdge("left")
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
                    color: "transparent"
                    PQHighlightMarker {
                        visible: rightmouse.hovered||(themenu.opened&&menuedge==="right")
                    }
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    PQText {
                        anchors.centerIn: parent
                        rotation: 90
                        font.weight: set_edge.current["right"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                        color: palette.text
                        text: set_edge.labels[set_edge.current["right"]]
                    }
                    PQMouseArea {
                        id: rightmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The action here is a screen edge action
                        text: qsTranslate("settingsmanager", "Click to change action")
                        onClicked: set_edge.changeEdge("right")
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
                    color: "transparent"
                    PQHighlightMarker {
                        visible: botmouse.hovered||(themenu.opened&&menuedge==="bottom")
                    }
                    border.width: 1
                    border.color: PQCLook.baseBorder
                    PQText {
                        anchors.centerIn: parent
                        font.weight: set_edge.current["bottom"]==="" ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold
                        color: palette.text
                        text: set_edge.labels[set_edge.current["bottom"]]
                    }
                    PQMouseArea {
                        id: botmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The action here is a screen edge action
                        text: qsTranslate("settingsmanager", "Click to change action")
                        onClicked: set_edge.changeEdge("bottom")
                    }
                }

                Item {
                    width: 50
                    height: 50
                }

            }

        },

        PQSettingsResetButton {
            onResetToDefaults: {

                current["top"] = PQCSettings.getDefaultForInterfaceEdgeTopAction()
                current["left"] = PQCSettings.getDefaultForInterfaceEdgeLeftAction()
                current["right"] = PQCSettings.getDefaultForInterfaceEdgeRightAction()
                current["bottom"] = PQCSettings.getDefaultForInterfaceEdgeBottomAction()
                currentChanged()

                set_edge.checkForChanges()

            }
        },

        /*********************************/

        PQSettingSubtitle {

            //: Settings title
            title: qsTranslate("settingsmanager", "Sensitivity")

            helptext: qsTranslate("settingsmanager", "The edge actions defined above are triggered whenever the mouse cursor gets close to the screen edge. The sensitivity determines how close to the edge the mouse cursor needs to be for this to happen. A value that is too sensitive might cause the edge action to sometimes be triggered accidentally.")

        },

        PQAdvancedSlider {
            id: sensitivity
            width: set_edge.contentWidth
            minval: 5
            maxval: 100
            suffix: " px"
            onValueChanged:
                set_edge.checkForChanges()
        },

        PQSettingsResetButton {
            onResetToDefaults: {

                sensitivity.setValue(PQCSettings.getDefaultForInterfaceHotEdgeSize()*5)

                set_edge.checkForChanges()

            }
        }

    ]

    property string menuedge: "top"

    PQMenu {
        id: themenu
        Repeater {
            id: menurep
            property list<string> curdat: set_edge.actions[set_edge.menuedge]
            model: curdat.length
            PQMenuItem {
                required property int modelData
                checkable: true
                property string act: modelData < menurep.curdat.length ? menurep.curdat[modelData] : ""
                text: set_edge.labels[act]
                checked: set_edge.current[set_edge.menuedge] === act
                checkableLikeRadioButton: true
                onCheckedChanged: {
                    if(checked && set_edge.current[set_edge.menuedge] !== act) {
                        set_edge.current[set_edge.menuedge] = act
                        set_edge.makeSureUnique(set_edge.menuedge, act)
                        set_edge.currentChanged()
                    }
                    checked = Qt.binding(function() { return current[set_edge.menuedge] === act; })
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

        menuedge = edge
        themenu.popup()

    }

    function handleEscape() {
        themenu.close()
        sensitivity.acceptValue()
    }

    function checkForChanges() {

        if(!settingsLoaded) return

        if(PQCSettings.generalAutoSaveSettings) {
            applyChanges()
            return
        }

        PQCConstants.settingsManagerSettingChanged = (current["top"] !== PQCSettings.interfaceEdgeTopAction ||
                                                      current["left"] !== PQCSettings.interfaceEdgeLeftAction ||
                                                      current["right"] !== PQCSettings.interfaceEdgeRightAction ||
                                                      current["bottom"] !== PQCSettings.interfaceEdgeBottomAction ||
                                                      sensitivity.hasChanged())

    }

    function load() {

        settingsLoaded = false

        current["top"] = PQCSettings.interfaceEdgeTopAction
        current["left"] = PQCSettings.interfaceEdgeLeftAction
        current["right"] = PQCSettings.interfaceEdgeRightAction
        current["bottom"] = PQCSettings.interfaceEdgeBottomAction
        currentChanged()

        sensitivity.loadAndSetDefault(PQCSettings.interfaceHotEdgeSize*5)

        PQCConstants.settingsManagerSettingChanged = false
        settingsLoaded = true

    }

    function applyChanges() {

        PQCSettings.interfaceEdgeTopAction = current["top"]
        PQCSettings.interfaceEdgeLeftAction = current["left"]
        PQCSettings.interfaceEdgeRightAction = current["right"]
        PQCSettings.interfaceEdgeBottomAction = current["bottom"]

        PQCSettings.interfaceHotEdgeSize = Math.round(sensitivity.value/5)
        sensitivity.saveDefault()

        PQCConstants.settingsManagerSettingChanged = false

    }

}
