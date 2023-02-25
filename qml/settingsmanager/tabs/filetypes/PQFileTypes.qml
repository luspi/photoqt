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

import "../../../elements"

Item {

    id: filetypes_top

    x: 10
    width: cont.width-20
    height: childrenRect.height

    signal checkAll()
    signal checkImg(var checked)
    signal checkPac(var checked)
    signal checkDoc(var checked)
    signal checkVid(var checked)

    Column {

        width: parent.width-10
        spacing: 10

        Column {
            spacing: 10
            Row {
                spacing: 10

                PQComboBox {
                    id: catCombo
                    y: (enableBut.height-height)/2
                            //: This is a category of files PhotoQt can recognize: any image format
                    model: [em.pty+qsTranslate("settingsmanager_filetypes", "images"),
                            //: This is a category of files PhotoQt can recognize: compressed files like zip, tar, cbr, 7z, etc.
                            em.pty+qsTranslate("settingsmanager_filetypes", "compressed files")+" (zip, cbr, ...)",
                            //: This is a category of files PhotoQt can recognize: documents like pdf, txt, etc.
                            em.pty+qsTranslate("settingsmanager_filetypes", "documents")+" (pdf, txt, ...)",
                            //: This is a type of category of files PhotoQt can recognize: videos like mp4, avi, etc.
                            em.pty+qsTranslate("settingsmanager_filetypes", "videos")]
                }

                PQButton {
                    id: enableBut
                    //: As in: "Enable all formats in the seleted category of file types"
                    text: em.pty+qsTranslate("settingsmanager_filetypes", "Enable")
                    onClicked:
                        parent.checkUncheck(1)
                }
                PQButton {
                    //: As in: "Disable all formats in the seleted category of file types"
                    text: em.pty+qsTranslate("settingsmanager_filetypes", "Disable")
                    onClicked:
                        parent.checkUncheck(0)
                }

                function checkUncheck(checked) {
                    if(catCombo.currentIndex == 0)
                        filetypes_top.checkImg(checked)
                    else if(catCombo.currentIndex == 1)
                        filetypes_top.checkPac(checked)
                    else if(catCombo.currentIndex == 2)
                        filetypes_top.checkDoc(checked)
                    else if(catCombo.currentIndex == 3)
                        filetypes_top.checkVid(checked)
                    else
                        console.log("Error: Unknown category selected:", catCombo.currentText)
                    listview.ftChanged()
                }

                Item {
                    width: 10
                    height: 1
                }

                PQButton {
                    //: As in "Enable every single file format PhotoQt can open in any category"
                    text: em.pty+qsTranslate("settingsmanager_filetypes", "Enable everything")
                    onClicked: {
                        filetypes_top.checkAll()
                        listview.ftChanged()
                    }
                }

            }
            Item {
                width: 1
                height: 1
            }
            PQText {
                id: countEnabled
                property int num: 0
                //: The %1 will be replaced with the number of file formats, please don't forget to add it.
                text:  em.pty+qsTranslate("settingsmanager_filetypes", "Currently there are %1 file formats enabled").arg("<b>"+num+"</b>")
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
                placeholderText: em.pty+qsTranslate("settingsmanager_filetypes", "Search by description or file ending")
            }

            PQLineEdit {
                id: filter_lib
                width: filetypes_top.width/2 -20
                placeholderText: em.pty+qsTranslate("settingsmanager_filetypes", "Search by image library or category")
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

                    PQText {
                        id: entry_desc
                        anchors {
                            left: checkenable.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        elide: Text.ElideRight
                        width: entry_rect.width/2 - checkenable.width-10
                        verticalAlignment: Text.AlignVCenter
                        text: "<b>" + listview.ft[index][2] + "</b> &nbsp;&nbsp; *." + listview.ft[index][0].split(",").join(", *.")
                        color: checkenable.checked ? "#dddddd" : "#aaaaaa"
                        Behavior on color { ColorAnimation { duration: 50 } }
                        textFormat: Text.StyledText
                    }

                    PQText {
                        id: entry_libs
                        anchors {
                            left: entry_desc.right
                            leftMargin: 10
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: entry_rect.width/2-10
                        verticalAlignment: Text.AlignVCenter
                        text: listview.ft[index].slice(4).join(", ")
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
                        tooltip: "<b>" + em.pty+qsTranslate("settingsmanager_filetypes", "File endings:") + "</b> *." + listview.ft[index][0].split(",").join(", *.")
                    }

                    Connections {
                        target: filetypes_top
                        onCheckAll: {
                            listview.ft[index][1] = 1
                        }
                        onCheckImg: {
                            if(listview.ft[index][3] === "img")
                                listview.ft[index][1] = checked
                        }
                        onCheckPac: {
                            if(listview.ft[index][3] === "pac")
                                listview.ft[index][1] = checked
                        }
                        onCheckDoc: {
                            if(listview.ft[index][3] === "doc")
                                listview.ft[index][1] = checked
                        }
                        onCheckVid: {
                            if(listview.ft[index][3] === "vid")
                                listview.ft[index][1] = checked
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
