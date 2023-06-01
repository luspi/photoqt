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

    id: filter_top

    popout: PQSettings.interfacePopoutFilter
    shortcut: "__filterImages"
    title: em.pty+qsTranslate("filter", "Filter images in current directory")

    //: Written on a clickable button - please keep short
    button1.text: em.pty+qsTranslate("filter", "Filter")

    button2.visible: true
    button2.text: genericStringCancel

    button3.visible: true
    //: Written on a clickable button - please keep short
    button3.text: em.pty+qsTranslate("filter", "Remove filter")

    onPopoutChanged:
        PQSettings.interfacePopoutFilter = popout

    button1.onClicked: {
        closeElement()
        if(!filenamecheck.checked && !rescheck.checked && !filesizecheck.checked)
            removeFilter()
        else
            setFilter()
    }

    button2.onClicked:
        closeElement()

    button3.onClicked: {
        closeElement()
        removeFilter()
    }

    content: [

        PQTextL {

            x: (parent.width-width)/2
            width: Math.min(parent.width, col.width*1.5)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: em.pty+qsTranslate("filter", "To filter by file extension, start the term with a dot. Setting the width or height of the resolution to 0 ignores that dimension.")

        },

        Item {
            width: 1
            height: 1
        },

        Column {

            id: col

            x: (parent.width-width)/2

            spacing: 10

            Row {

                id: filenameextrow

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
                    font.weight: baselook.boldweight
                    font.pointSize: baselook.fontsize_l
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
                PQText {
                    y: (resheight.height-height)/2
                    enabled: rescheck.checked
                    font.weight: baselook.boldweight
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
                    font.weight: baselook.boldweight
                    font.pointSize: baselook.fontsize_l
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

                width: parent.width

                height: rescheck.checked ? childrenRect.height : 0
                Behavior on height { NumberAnimation { duration: 250 } }

                clip: true

                PQText {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    text: em.pty+qsTranslate("filter", "Please note that filtering by image resolution can take a little while, depending on the number of images in the folder.")

                }

            }

        }

    ]

    Connections {
        target: loader
        onFilterPassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1 && !filefoldermodel.filterCurrentlyActive)
                    return
                opacity = 1
                variables.visibleItem = "filter"
            } else if(what == "hide") {
                button2.clicked()
            } else if(what == "removeFilter") {
                button3.clicked()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    button2.clicked()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    button1.clicked()
            }
        }
    }

    function closeElement() {
        filter_top.opacity = 0
        variables.visibleItem = ""
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
