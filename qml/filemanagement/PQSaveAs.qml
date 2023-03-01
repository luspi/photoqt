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
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: saveas_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Rectangle {

        anchors.fill: parent
        color: "#f41f1f1f"

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

                PQTextXL {
                    id: heading
                    x: (insidecont.width-width)/2
                    font.weight: baselook.boldweight
                    //: This is a title, similar to all the 'save as' options in many programs.
                    text: em.pty+qsTranslate("filemanagement", "Save file as")
                }

                PQTextL {
                    id: filename
                    x: (insidecont.width-width)/2
                    color: "grey"
                    text: "this_is_the_filename.jpg"
                }

                Item {
                    width: 1
                    height: 1
                }

                PQTextL {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be saved!")
                }

                PQTextL {
                    id: abort
                    x: (insidecont.width-width)/2
                    color: "orange"
                    visible: false
                    horizontalAlignment: Qt.AlignHCenter
                    //: 'Operation' here is the operation of saving an image in a new format
                    text: em.pty+qsTranslate("filemanagement", "Operation cancelled")
                }

                PQLineEdit {
                    id: formatsfilter
                    x: (insidecont.width-width)/2
                    width: formatsflick.width
                    //: This is a short hint informing the user that here they can 'filter all the possible file formats'
                    placeholderText: em.pty+qsTranslate("filemanagement", "Filter formats")
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

                            maximumFlickVelocity: 1000
                            boundsBehavior: Flickable.StopAtBounds

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

                                PQText {
                                    id: formatsname
                                    x: 5
                                    y: 5
                                    width: parent.width-10
                                    text: formatsview.data[index][2]
                                }

                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    tooltip: "<b>" + formatsview.data[index][2] + "</b><br>*." + formatsview.data[index][1].split(",").join(", *.")
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
                    PQText {
                        id: newfilename_label
                        y: (newfilename.height-height)/2
                        text: em.pty+qsTranslate("filemanagement", "New filename") + ":"
                    }

                    PQLineEdit {
                        id: newfilename
                        width: formatsflick.width-newfilename_label.width-5
                        placeholderText: em.pty+qsTranslate("filemanagement", "New filename")

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
                            text: em.pty+qsTranslate("filemanagement", "Choose location and save file")
                            border.width: 1
                            border.color: "black"
                            enabled: formatsview.currentIndex != -1
                            onClicked: {
                                var stat = handlingManipulation.chooseLocationAndConvertImage(filefoldermodel.currentFilePath, newfilename.text, formatsview.data[formatsview.currentIndex][1])
                                if(stat == -1) {
                                    abort.visible = true
                                    hideErrorAbort.restart()
                                } else if(stat == 1) {
                                    saveas_top.opacity = 0
                                    variables.visibleItem = ""
                                } else {
                                    error.visible = true
                                    hideErrorAbort.restart()
                                }

                            }
                        }
                        PQButton {
                            scale: 0.8
                            id: button_cancel
                            text: genericStringCancel
                            border.width: 1
                            border.color: "black"
                            renderType: Text.QtRendering
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
                    if(filefoldermodel.current == -1)
                        return
                    opacity = 1
                    error.visible = false
                    abort.visible = false
                    variables.visibleItem = "filesaveas"
                    filename.text = handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath)
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

    }

    Timer {
        id: hideErrorAbort
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            error.visible = false
            abort.visible = false
        }
    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutFileSaveAs ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutFileSaveAs)
                    saveas_window.storeGeometry()
                button_cancel.clicked()
                PQSettings.interfacePopoutFileSaveAs= !PQSettings.interfacePopoutFileSaveAs
                HandleShortcuts.executeInternalFunction("__saveAs")
            }
        }
    }

}
