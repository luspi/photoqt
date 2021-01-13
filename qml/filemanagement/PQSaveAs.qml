/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../elements"

Item {

    id: saveas_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.fileSaveAsPopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#ee000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 10

                Text {
                    id: heading
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    text: em.pty+qsTranslate("filemanagement", "Save file as")
                }

                Text {
                    id: filename
                    x: (insidecont.width-width)/2
                    color: "grey"
                    font.pointSize: 15
                    text: "this_is_the_filename.jpg"
                }

                Text {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    font.pointSize: 15
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be converted!")
                }

                PQLineEdit {
                    id: formatsfilter
                    x: (insidecont.width-width)/2
                    width: formatsflick.width
                    placeholderText: "Filter formats"
                }

                Rectangle {

                    x: (insidecont.width-width)/2

                    width: Math.min(saveas_top.width*0.5, 500)
                    height: 300

                    color: "#44000000"
                    border.width: 1
                    border.color: "#66ffffff"

                    Flickable {

                        id: formatsflick

                        anchors.fill: parent
                        anchors.margins: 1
                        anchors.rightMargin: 0

                        clip: true

                        ListView {

                            id: formatsview

                            anchors.fill: parent
                            anchors.leftMargin: -1
                            anchors.rightMargin: -1

                            ScrollBar.vertical: PQScrollBar { id: scroll }

                            model: data.length

                            property var data: []

                            property int currentHover: -1

                            onCurrentIndexChanged: {
                                if(currentIndex == -1) return
                                var newSuffix = data[currentIndex][1].split(",")[0]
                                newfilename.text = handlingFileDir.replaceSuffix(newfilename.text, newSuffix)
                                newfilename.forceActiveFocus()
                            }

                            Component.onCompleted: {
                                data = PQImageFormats.getWriteableFormats()
                                currentIndex = -1
                            }

                            delegate: Rectangle {
                                width: formatsview.width
                                height: visible ? (formatsname.height+10) : 0
                                color: formatsview.currentIndex==index ? "#88777777" : (formatsview.currentHover==index ? "#88444444" : "#88222222")
                                border.width: 1
                                border.color: "black"

                                visible: formatsfilter.text=="" || formatsview.data[index][1].toLowerCase().indexOf(formatsfilter.text.toLowerCase())!=-1 || formatsview.data[index][2].toLowerCase().indexOf(formatsfilter.text.toLowerCase())!=-1

                                Text {
                                    id: formatsname
                                    x: 5
                                    y: 5
                                    width: parent.width-10
                                    color: "white"
                                    text: formatsview.data[index][2]
                                }

                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:
                                        formatsview.currentHover = index
                                    onClicked:
                                        formatsview.currentIndex = index
                                }
                            }
                        }

                    }

                }

                Row {
                    x: (insidecont.width-width)/2
                    spacing: 5
                    Text {
                        id: newfilename_label
                        y: (newfilename.height-height)/2
                        text: "New filename:"
                        color: "white"
                    }

                    PQLineEdit {
                        id: newfilename
                        width: formatsflick.width-newfilename_label.width-5
                        placeholderText: "New filename"

                    }
                }

                Item {

                    id: butcont

                    x: 0
                    width: insidecont.width
                    height: childrenRect.height

                    Row {

                        spacing: 5

                        x: (parent.width-width)/2

                        PQButton {
                            id: button_ok
                            text: em.pty+qsTranslate("filemanagement", "Choose location and convert")
                            borderWidth: 1
                            borderColor: "black"
                            enabled: formatsview.currentIndex != -1
                            onClicked: {
                                if(handlingManipulation.chooseLocationAndConvertImage(variables.allImageFilesInOrder[variables.indexOfCurrentImage], newfilename.text, formatsview.data[formatsview.currentIndex][1])) {
                                    saveas_top.opacity = 0
                                    variables.visibleItem = ""
                                } else
                                    error.visible = true

                            }
                        }
                        PQButton {
                            scale: 0.8
                            id: button_cancel
                            text: genericStringCancel
                            borderWidth: 1
                            borderColor: "black"
                            onClicked: {
                                saveas_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }

                    }

                }

            }

        }

        Connections {
            target: loader
            onFileSaveAsPassOn: {
                if(what == "show") {
                    if(variables.indexOfCurrentImage == -1)
                        return
                    opacity = 1
                    error.visible = false
                    variables.visibleItem = "filesaveas"
                    filename.text = handlingFileDir.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    newfilename.text = filename.text
                    formatsfilter.forceActiveFocus()
                    formatsview.currentIndex = -1
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                }
            }
        }

        Shortcut {
            sequence: "Esc"
            enabled: PQSettings.fileSaveAsPopoutElement
            onActivated: button_cancel.clicked()
        }

        Shortcut {
            sequences: ["Enter", "Return"]
            enabled: PQSettings.fileSaveAsPopoutElement
            onActivated: button_ok.clicked()
        }

    }

}
