/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "status information")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "The status information shows some basic data about the current folder and photo in the top left corner of the window. The items can be reordered using drag-and-drop.")
    content: [

        Column {

            spacing: 10

            PQCheckbox {
                id: status_show
                text: em.pty+qsTranslate("settingsmanager_interface", "Show status information")
            }

            Rectangle {
                enabled: status_show.checked
                opacity: enabled ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }
                width: set.contwidth
                height: 60+(scrollbar.visible ? (scrollbar.height+5) : 0)
                color: "#333333"
                ListView {
                    id: avail

                    x: 5
                    y: 5

                    width: parent.width-10
                    height: parent.height-10

                    clip: true
                    orientation: ListView.Horizontal
                    spacing: 5

                    ScrollBar.horizontal: PQScrollBar { id: scrollbar }

                    property int dragItemIndex: -1

                    property var widths: []

                    property var disp: {
                        //: Please keep short! The counter shows where we are in the folder.
                        "counter": em.pty+qsTranslate("settingsmanager_interface", "counter"),
                        //: Please keep short!
                        "filename": em.pty+qsTranslate("settingsmanager_interface", "filename"),
                        //: Please keep short!
                        "filepathname": em.pty+qsTranslate("settingsmanager_interface", "filepath"),
                        //: Please keep short! This is the image resolution.
                        "resolution": em.pty+qsTranslate("settingsmanager_interface", "resolution"),
                        //: Please keep short! This is the current zoom level.
                        "zoom": em.pty+qsTranslate("settingsmanager_interface", "zoom"),
                        //: Please keep short! This is the rotation of the current image
                        "rotation": em.pty+qsTranslate("settingsmanager_interface", "rotation"),
                        //: Please keep short! This is the filesize of the current image.
                        "filesize": em.pty+qsTranslate("settingsmanager_interface", "filesize")
                    }

                    model: ListModel {
                        id: model
                    }

                    delegate: Item {
                        id: deleg
                        width: Math.max.apply(Math, avail.widths)
                        height: avail.height-(scrollbar.visible ? (scrollbar.height+5) : 0)

                        Rectangle {
                            id: dragRect
                            width: deleg.width
                            height: deleg.height
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#666666"
                            radius: 5
                            Text {
                                id: txt
                                x: (parent.width-width)/2
                                y: (parent.height-height)/2
                                text: avail.disp[name]
                                font.bold: true
                                font.pointSize: 10
                                color: "white"
                                onWidthChanged: {
                                    avail.widths.push(width+20)
                                    avail.widthsChanged()
                                }
                            }
                            PQMouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                drag.target: parent
                                drag.axis: Drag.XAxis
                                drag.onActiveChanged: {
                                    if (mouseArea.drag.active) {
                                        avail.dragItemIndex = index;
                                    }
                                    dragRect.Drag.drop();
                                }
                                cursorShape: Qt.OpenHandCursor
                                onPressed:
                                    cursorShape = Qt.ClosedHandCursor
                                onReleased:
                                    cursorShape = Qt.OpenHandCursor
                            }
                            states: [
                                State {
                                    when: dragRect.Drag.active
                                    ParentChange {
                                        target: dragRect
                                        parent: set
                                    }

                                    AnchorChanges {
                                        target: dragRect
                                        anchors.horizontalCenter: undefined
                                        anchors.verticalCenter: undefined
                                    }
                                }
                            ]

                            Drag.active: mouseArea.drag.active
                            Drag.hotSpot.x: 0
                            Drag.hotSpot.y: 0

                            Image {

                                x: parent.width-width
                                y: 0
                                width: 20
                                height: 20

                                source: "/other/close.svg"
                                sourceSize: Qt.size(width, height)

                                opacity: closemouse.containsMouse ? 0.8 : 0.2
                                Behavior on opacity { NumberAnimation { duration: 150 } }

                                PQMouseArea {
                                    id: closemouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked:
                                        avail.model.remove(index, 1)
                                }

                            }

                        }

                    }
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    onPositionChanged: {
                        var newindex = avail.indexAt(drag.x, drag.y)
                        if(newindex != -1 && newindex != avail.dragItemIndex) {
                            avail.model.move(avail.dragItemIndex, newindex, 1)
                            avail.dragItemIndex = newindex
                        }
                    }
                }
            }

            Row {
                enabled: status_show.checked
                spacing: 10
                PQComboBox {
                    id: combo_add
                    y: (but_add.height-height)/2
                    property var data: [
                        //: Please keep short! The counter shows where we are in the folder.
                        ["counter", em.pty+qsTranslate("settingsmanager_interface", "counter")],
                        //: Please keep short!
                        ["filename", em.pty+qsTranslate("settingsmanager_interface", "filename")],
                        //: Please keep short!
                        ["filepathname", em.pty+qsTranslate("settingsmanager_interface", "filepath")],
                        //: Please keep short! This is the image resolution.
                        ["resolution", em.pty+qsTranslate("settingsmanager_interface", "resolution")],
                        //: Please keep short! This is the current zoom level.
                        ["zoom", em.pty+qsTranslate("settingsmanager_interface", "zoom")],
                        //: Please keep short! This is the rotation of the current image
                        ["rotation", em.pty+qsTranslate("settingsmanager_interface", "rotation")],
                        //: Please keep short! This is the filesize of the current image.
                        ["filesize", em.pty+qsTranslate("settingsmanager_interface", "filesize")]
                    ]
                    lineBelowItem: 4
                    property var modeldata: []
                    model: modeldata
                    Component.onCompleted: {
                        var tmp = []
                        for(var i = 0; i < data.length; ++i)
                            tmp.push(data[i][1])
                        modeldata = tmp
                    }
                }
                PQButton {
                    id: but_add
                    //: This is written on a button that is used to add a selected block to the status info section.
                    text: em.pty+qsTranslate("settingsmanager_interface", "Add")
                    onClicked:
                        model.append({name: combo_add.data[combo_add.currentIndex][0]})
                }
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {

            status_show.checked = PQSettings.interfaceStatusInfoShow

            model.clear()
            var setprops = PQSettings.interfaceStatusInfoList
            for(var j = 0; j < setprops.length; ++j)
                model.append({name: setprops[j]})
        }

        onSaveAllSettings: {

            PQSettings.interfaceStatusInfoShow = status_show.checked

            var opts = []
            for(var i = 0; i < model.count; ++i)
                opts.push(model.get(i).name)
            PQSettings.interfaceStatusInfoList = opts
        }

    }

}
