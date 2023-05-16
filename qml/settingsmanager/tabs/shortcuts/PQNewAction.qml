/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"
import "../../../shortcuts/mouseshortcuts.js" as PQAnalyseMouse

Rectangle {

    id: newaction_top

    parent: settingsmanager_top

    anchors.fill: parent

    color: "#ee000000"

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    property var categories: [
        "viewingimages",
        "currentimage",
        "currentfolder",
        "interface",
        "other"
    ]

    property var categoriesToIndex: {
        "viewingimages" : 0,
        "currentimage" : 1,
        "currentfolder" : 2,
        "interface" : 3,
        "other" : 4
    }

    property var categoryTitles: {
        "viewingimages" : em.pty+qsTranslate("settingsmanager", "Viewing images"),
        "currentimage" : em.pty+qsTranslate("settingsmanager", "Current image"),
        "currentfolder" : em.pty+qsTranslate("settingsmanager", "Current folder"),
        "interface" : em.pty+qsTranslate("settingsmanager", "Interface"),
        "other" : em.pty+qsTranslate("settingsmanager", "Other")
    }

    property var descriptions: {
        "viewingimages" : "These actions affect the behavior of PhotoQt when viewing images. They include actions for navigating between images, and manipulating the current image (zoom, flip, rotation). Multiple actions can be combined for the same shortcut.",
        "currentimage" : "These actions are certain things that can be done with the currently viewed image. They typically do not affect any of the other images. Multiple actions can be combined for the same shortcut.",
        "currentfolder" : "These are actions affecting the currently loaded folder as a whole and not just single images. Multiple actions can be combined for the same shortcut.",
        "interface" : "These affect the status and behaviour of various interface elements, regardless of the image loaded, or whether anything is loaded at all.",
        "other" : "These ations quite simply don't really fit into any other category."
    }

    property var actionsByCategory: [[], [], [], [], []]

    Component.onCompleted: {
        //: A shortcuts category: actions with current folder

        for(var cmd in tab_shortcuts.actions) {

            var cat = tab_shortcuts.actions[cmd][1]
            var idx = categoriesToIndex[cat]
            var dsc = tab_shortcuts.actions[cmd][0]

            actionsByCategory[idx].push([cmd,dsc])

        }

        actionsByCategoryChanged()

    }

    property int selectedCategory: 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    PQTextL {
        id: titletxt
        y: 10
        width: parent.width
        font.weight: baselook.boldweight
        horizontalAlignment: Text.AlignHCenter
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Add new action")
    }

    Rectangle {

        id: insidecont

        x: (parent.width-width)/2
        y: (parent.height-height)/2-10
        width: Math.min(800, parent.width)
        height: Math.min(600, parent.height-titletxt.height-butcont.height-40)

        color: "#220000"
        border.width: 1
        border.color: "#330000"

        Rectangle {
            color: "blue"

            width: 300
            height: parent.height

            ListView {

                orientation: ListView.Vertical
                interactive: false

                y: (parent.height-height)/2

                width: parent.width
                height: insidecont.height

                model: 5

                delegate:
                    Rectangle {
                        width: parent.width
                        height: insidecont.height/5
                        color: "green"
                        PQTextL {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.weight: baselook.boldweight
                            text: categoryTitles[categories[index]]
                        }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                newaction_top.selectedCategory = index
                            }
                        }
                    }

            }

        }

        Rectangle {
            color: "yellow"

            x: 300
            width: parent.width-300
            height: parent.height

            ListView {
                id: actionsview
                width: parent.width
                height: parent.height
                orientation: ListView.Vertical
                model: actionsByCategory[selectedCategory].length
                spacing: 4
                clip: true
                ScrollBar.vertical: PQScrollBar { id: scroll }
                delegate:
                    Rectangle {
                        width: actionsview.width-(scroll.visible ? scroll.width : 0)
                        height: dsclabel.height+10
                        color: "orange"
                        PQText {
                            id: dsclabel
                            x: 5
                            y: 5
                            width: parent.width-10
                            text: actionsByCategory[selectedCategory][index][1]
                        }
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("add action:", actionsByCategory[selectedCategory][index][0])
                            }
                        }
                    }
            }

        }

    }


    Item {

        id: butcont
        x: (parent.width-width)/2
        y: parent.height-height-20
        width: row.width
        height: row.height

        Row {
            id: row
            spacing: 10
            PQButton {
                id: savebut
                text: genericStringSave
                onClicked: {

                }
            }
            PQButton {
                id: cancelbut
                text: genericStringCancel
                onClicked: {

                }
            }
        }

    }

    function show() {

        newaction_top.opacity = 1
        settingsmanager_top.modalWindowOpen = true
    }

}
