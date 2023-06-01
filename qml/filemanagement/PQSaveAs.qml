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
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: saveas_top

    popout: PQSettings.interfacePopoutFileSaveAs
    shortcut: "__saveAs"
    title: em.pty+qsTranslate("filemanagement", "Save file as")

    button1.text: em.pty+qsTranslate("filemanagement", "Choose location and save file")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutFileSaveAs = popout

    button1.onClicked:
        performSaveAs()

    button2.onClicked:
        closeElement()

    content: [

        PQTextL {
            id: filename
            x: (parent.width-width)/2
            color: "grey"
            text: "this_is_the_filename.jpg"
        },

        Item {
            width: 1
            height: 1
        },

        PQTextL {
            id: error
            x: (parent.width-width)/2
            color: "red"
            visible: false
            horizontalAlignment: Qt.AlignHCenter
            text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be saved!")
        },

        PQTextL {
            id: abort
            x: (parent.width-width)/2
            color: "orange"
            visible: false
            horizontalAlignment: Qt.AlignHCenter
            //: 'Operation' here is the operation of saving an image in a new format
            text: em.pty+qsTranslate("filemanagement", "Operation cancelled")
        },

        PQLineEdit {
            id: formatsfilter
            x: (parent.width-width)/2
            width: formatsflick.width
            //: This is a short hint informing the user that here they can 'filter all the possible file formats'
            placeholderText: em.pty+qsTranslate("filemanagement", "Filter formats")
        },

        Rectangle {

            x: (parent.width-width)/2

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

        },

        Row {
            x: (parent.width-width)/2
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

    ]

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
                saveas_top.closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    saveas_top.closeElement()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    saveas_top.performSaveAs()
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

    function closeElement() {
        saveas_top.opacity = 0
        variables.visibleItem = ""
    }

    function performSaveAs() {
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
