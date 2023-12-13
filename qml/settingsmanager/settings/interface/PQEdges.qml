import QtQuick
import QtQuick.Controls

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

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Edges")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "Moving the mouse cursor to the edges of the application window can trigger the visibility of some things, like the main menu, thumbnails, or metadata. Here you can choose what is triggered by which window edge. Note that the main menu is fixed to the right window edge and cannot be moved or disabled.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Item {
            width: 1
            height: 10
        }

        Column {

            x: (parent.width-width)/2

            Row {

                Item {
                    width: 75
                    height: 75
                }

                Rectangle {
                    id: topedge
                    width: 300
                    height: 75
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
                    width: 75
                    height: 75
                }

            }

            Row {

                Rectangle {
                    id: leftedge
                    width: 75
                    height: 300
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
                    width: 300
                    height: 300
                }

                Rectangle {
                    id: rightedge
                    width: 75
                    height: 300
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
                    width: 75
                    height: 75
                }

                Rectangle {
                    id: botedge
                    width: 300
                    height: 75
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
                    width: 75
                    height: 75
                }

            }

        }

        /**********************************************************************/
        PQSettingsSeparator {}
        /**********************************************************************/

        PQTextXL {
            font.weight: PQCLook.fontWeightBold
            //: Settings title
            text: qsTranslate("settingsmanager", "Sensitivity")
            font.capitalization: Font.SmallCaps
        }

        PQText {
            width: setting_top.width
            text: qsTranslate("settingsmanager", "The edge actions defined above are triggered whenever the mouse cursor gets close to the screen edge. The sensitivity determines how close to the edge the mouse cursor needs to be for this to happen. A value that is too sensitive might cause the edge action to sometimes be triggered accidentally.")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
            x: (parent.width-width)/2
            PQText {
                text: "5px"
            }
            PQSlider {
                id: sensitivity
                from: 1
                to: 20
                value: PQCSettings.interfaceHotEdgeSize
                onValueChanged: checkDefault()
            }
            PQText {
                text: "100px"
            }
        }

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("settingsmanager", "current value:") + " " + sensitivity.value*5 + " px"
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

        settingChanged = false

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
