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
import QtQuick.Dialogs 1.2

import "../elements"
//import "../loadfiles.js" as LoadFiles
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: filter_top

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
        color: "#f8000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !PQSettings.interfacePopoutFilter
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            x: (parent.width-width)/2
            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                id: inside

                width: parent.width
                spacing: 20

                property int maxrowwidth: Math.max(filenameextrow.width, Math.max(imageresrow.width, filesizerow.width))

                Text {
                    id: heading
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    text: em.pty+qsTranslate("filter", "Filter images in current directory")
                }

                Text {

                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    width: Math.min(inside.maxrowwidth+100, inside.width)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    text: em.pty+qsTranslate("filter", "To filter by file extension, start the term with a dot. Setting the width or height of the resolution to 0 ignores that dimension.")

                }

                Row {

                    id: filenameextrow

                    x: (inside.width-inside.maxrowwidth)/2

                    spacing: 10

                    PQCheckbox {

                        id: filenamecheck

                        y: (filenameedit.height-height)/2

                        text: em.pty+qsTranslate("filter", "File name/extension:")
                    }

                    PQLineEdit {

                        id: filenameedit

                        enabled: filenamecheck.checked

                        width: 300
                        height: 40

                        placeholderText: em.pty+qsTranslate("filter", "Enter terms")
                    }

                }

                Row {

                    id: imageresrow

                    x: (inside.width-inside.maxrowwidth)/2

                    spacing: 10

                    PQCheckbox {
                        id: rescheck
                        y: (reswidth.height-height)/2
                        text: "Image Resolution"
                    }

                    PQButton {
                        id: resgreaterless
                        y: (filesize.height-height)/2
                        enabled: rescheck.checked
                        property bool greater: true
                        text: greater ? ">" : "<"
                        font.bold: true
                        font.pointSize: 15
                        tooltip: greater ?
                                     //: used as tooltip in the sense of 'image resolution GREATER THAN 123x123'
                                     em.pty+qsTranslate("filter", "greater than") :
                                     //: used as tooltip in the sense of 'image resolution LESS THAN 123x123'
                                     em.pty+qsTranslate("filter", "less than")
                        onClicked:
                            greater = !greater
                    }

                    PQSpinBox {
                        id: reswidth
                        enabled: rescheck.checked
                        from: 0
                        to: 99999999
                    }
                    Text {
                        y: (resheight.height-height)/2
                        color: rescheck.checked ? "white" : "#888888"
                        font.bold: true
                        text: "x"
                    }
                    PQSpinBox {
                        id: resheight
                        enabled: rescheck.checked
                        from: 0
                        to: 99999999
                    }

                }

                Row {

                    id: filesizerow

                    x: (inside.width-inside.maxrowwidth)/2

                    spacing: 10

                    PQCheckbox {
                        id: filesizecheck
                        y: (filesize.height-height)/2
                        text: em.pty+qsTranslate("filter", "File size")
                    }

                    PQButton {
                        id: filesizegreaterless
                        y: (filesize.height-height)/2
                        enabled: filesizecheck.checked
                        property bool greater: true
                        text: greater ? ">" : "<"
                        font.bold: true
                        font.pointSize: 15
                        tooltip: greater ?
                                     //: used as tooltip in the sense of 'file size GREATER THAN 123 KB/MB'
                                     em.pty+qsTranslate("filter", "greater than") :
                                     //: used as tooltip in the sense of 'file size LESS THAN 123 KB/MB'
                                     em.pty+qsTranslate("filter", "less than")
                        onClicked:
                            greater = !greater
                    }

                    PQSpinBox {
                        id: filesize
                        enabled: filesizecheck.checked
                        from: 0
                        to: 99999999
                    }

                    PQRadioButton {
                        id: filesizekb
                        y: (filesize.height-height)/2
                        text: "KB"
                        checked: true
                        enabled: filesizecheck.checked
                    }
                    PQRadioButton {
                        id: filesizemb
                        y: (filesize.height-height)/2
                        text: "MB"
                        enabled: filesizecheck.checked
                    }

                }

                Item {

                    x: (parent.width-width)/2
                    width: Math.min(inside.maxrowwidth+100, inside.width)

                    height: rescheck.checked ? childrenRect.height : 1
                    Behavior on height { NumberAnimation { duration: 250 } }

                    clip: true

                    Text {
                        color: "white"
                        font.pointSize: 10
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap

                        text: em.pty+qsTranslate("filter", "Please note that filtering by image resolution can take a little while, depending on the number of images in the folder.")

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
                            //: Written on a clickable button - please keep short
                            text: em.pty+qsTranslate("filter", "Filter")
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                                if(!filenamecheck.checked && !rescheck.checked && !filesizecheck.checked)
                                    removeFilter()
                                else
                                    setFilter()
                            }
                        }
                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }
                        PQButton {
                            scale: 0.8
                            id: button_removefilter
                            //: Written on a clickable button - please keep short
                            text: em.pty+qsTranslate("filter", "Remove filter")
                            renderType: Text.QtRendering
                            onClicked: {
                                filter_top.opacity = 0
                                variables.visibleItem = ""
                                removeFilter()
                            }
                        }

                    }

                }

            }

        }

        Connections {
            target: loader
            onFilterPassOn: {
                if(what == "show") {
                    if(filefoldermodel.current == -1 && !filefoldermodel.filterCurrentlyActive)
                        return
                    opacity = 1
                    variables.visibleItem = "filter"
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "removeFilter") {
                    removeFilter()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                }
            }
        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutFilter ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutFilter)
                    filter_window.storeGeometry()
                button_cancel.clicked()
                PQSettings.interfacePopoutFilter = !PQSettings.interfacePopoutFilter
                HandleShortcuts.executeInternalFunction("__filterImages")
            }
        }
    }

    function setFilter() {

        var fileNameFilter = []
        var fileEndingFilter = []

        // filter out search terms and search suffixes
        if(filenamecheck.checked) {
            var spl = filenameedit.text.split(" ")
            for(var iSpl = 0; iSpl < spl.length; ++iSpl) {
                if(spl[iSpl][0] == ".")
                    fileEndingFilter.push(spl[iSpl].slice(1))
                else {
                    fileNameFilter.push(spl[iSpl])
                }
            }
        }
        filefoldermodel.nameFilters = fileEndingFilter
        filefoldermodel.filenameFilters = fileNameFilter

        if(rescheck.checked)
            filefoldermodel.imageResolutionFilter = Qt.size((resgreaterless.greater ? 1 : -1)*reswidth.value, (resgreaterless.greater ? 1 : -1)*resheight.value)
        else
            filefoldermodel.imageResolutionFilter = Qt.size(0,0)

        if(filesizecheck.checked) {
            console.log(filesize.value)
            variables.filterExactFileSizeSet = filesize.value+(filesizekb.checked ? " KB" : " MB")
            filefoldermodel.fileSizeFilter = (filesizegreaterless.greater ? 1 : -1)*filesize.value*(filesizekb.checked ? 1024 : (1024*1024))
        } else
            filefoldermodel.fileSizeFilter = 0

    }

    function removeFilter() {

        filenamecheck.checked = false
        rescheck.checked = false
        filesizecheck.checked = false

        filefoldermodel.nameFilters = []
        filefoldermodel.filenameFilters = []
        filefoldermodel.imageResolutionFilter = Qt.size(0,0)
        filefoldermodel.fileSizeFilter = 0

    }

}
