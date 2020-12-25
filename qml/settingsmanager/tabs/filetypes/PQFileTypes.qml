/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

import "../../../elements"

Item {

    id: filetypes_top

    x: 10
    width: cont.width-20
    height: childrenRect.height

    signal checkAll()
    signal checkDefault()

    Column {

        width: parent.width-10
        spacing: 10

        Column {
            spacing: 10
            Row {
                spacing: 10
                PQButton {
                    text: "Select all default image formats"
                    onClicked: {
                        filetypes_top.checkDefault()
                        listview.ftChanged()
                    }
                }
                PQButton {
                    text: "Select all image formats"
                    onClicked: {
                        if(handlingGeneral.askForConfirmation("Enable all image formats?", "This will also enable all untested image formats.")) {
                            filetypes_top.checkAll()
                            listview.ftChanged()
                        }
                    }
                }
            }
            Item {
                width: 1
                height: 1
            }
            Text {
                id: countEnabled
                property int num: 0
                color: "white"
                font.pointSize: 12
                text: "Currently there are %1 image formats enabled".arg("<b>"+num+"</b>")
                Connections {
                    target: listview
                    onFtChanged:
                        countEnabled.countFormats()
                }
                Component.onCompleted: {
                    countEnabled.countFormats()
                }
                function countFormats() {
                    var c = 0
                    for(var i = 0; i< listview.ft.length; ++i)
                        if(listview.ft[i][1] == 1) c += 1
                    countEnabled.num = c
                }
            }
            Item {
                width: 1
                height: 1
            }
        }

        Row {
            spacing: 10

            PQLineEdit {
                id: filter_desc
                width: filetypes_top.width/2
                placeholderText: "Search by description"
            }

            PQLineEdit {
                id: filter_lib
                width: filetypes_top.width/2 -20
                placeholderText: "Search by image library"
            }
        }

        ListView {

            id: listview

            width: parent.width
            height: childrenRect.height
            boundsBehavior: Flickable.StopAtBounds

            property var ft: PQImageFormats.getAllFormats()

            model: ft.length

            spacing: 0

            delegate:
                Rectangle {

                    id: entry_rect

                    width: listview.width

                    clip: true

                    height: ((filter_desc.text==""||(entry_desc.text.toLowerCase().indexOf(filter_desc.text.toLowerCase()) != -1 || listview.ft[index][0].toLowerCase().indexOf(filter_desc.text.toLowerCase()) != -1)) &&
                             (filter_lib.text==""||(entry_libs.text.toLowerCase().indexOf(filter_lib.text.toLowerCase()) != -1))) ? 50 : 0
                    Behavior on height { NumberAnimation { duration: 100 } }

                    color: index%2==0 ? "#22ffffff" : "#22cccccc"
                    visible: height > 0

                    PQCheckbox {
                        id: checkenable
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        checked: listview.ft[index][1]
                        onClicked: {
                            listview.ft[index][1] = !listview.ft[index][1]
                            listview.ftChanged()
                        }
                    }

                    Text {
                        id: entry_desc
                        anchors {
                            left: checkenable.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: entry_rect.width/2 - checkenable.width-10
                        verticalAlignment: Text.AlignVCenter
                        text: listview.ft[index][2]
                        color: checkenable.checked ? "#ffffff" : "#aaaaaa"
                        Behavior on color { ColorAnimation { duration: 50 } }
                    }

                    Text {
                        id: entry_libs
                        anchors {
                            left: entry_desc.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: entry_rect.width/2-10
                        verticalAlignment: Text.AlignVCenter
                        text: listview.ft[index].slice(3).join(", ")
                        color: checkenable.checked ? "#bbbbbb" : "#666666"
                        Behavior on color { ColorAnimation { duration: 50 } }
                    }

                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            listview.ft[index][1] = !listview.ft[index][1]
                            listview.ftChanged()
                        }
                        tooltip: "<b>File endings:</b> *." + listview.ft[index][0].split(",").join(", *.")
                    }

                    Connections {
                        target: filetypes_top
                        onCheckAll:
                            listview.ft[index][1] = 1
                        onCheckDefault: {
                            listview.ft[index][1] = 1
                            if(PQImageFormats.getDefaultEnabledFormats().indexOf(listview.ft[index][0]) == -1)
                                listview.ft[index][1] = 0
                        }
                    }

                }

        }

    }

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            listview.ft = PQImageFormats.getAllFormats()
        }

        onSaveAllSettings: {
            PQImageFormats.setAllFormats(listview.ft)
        }

    }

}
