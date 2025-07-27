/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import PhotoQt.Modern
import PhotoQt.Shared

PQTemplateFullscreen {

    id: filter_top

    thisis: "filter"
    popout: PQCSettings.interfacePopoutFilter 
    forcePopout: PQCWindowGeometry.filterForcePopout 
    shortcut: "__filterImages"
    title: qsTranslate("filter", "Filter images in current directory")

    //: Written on a clickable button - please keep short
    button1.text: qsTranslate("filter", "Filter")

    button2.visible: true
    button2.text: genericStringCancel

    button3.visible: true
    //: Written on a clickable button - please keep short
    button3.text: qsTranslate("filter", "Remove filter")
    button3.font.weight: PQCLook.fontWeightNormal 

    onPopoutChanged:
        PQCSettings.interfacePopoutFilter = popout 

    button1.onClicked: {
        if(!filenamecheck.checked && !rescheck.checked && !filesizecheck.checked)
            removeFilter()
        else
            setFilter()
        hide()
    }

    button2.onClicked:
        hide()

    button3.onClicked: {
        hide()
        removeFilter()
    }

    property int countOpenSpin: 0
    signal closeAllSpinExcept(var senderid)

    content: [

        PQTextL {

            x: (parent.width-width)/2
            width: Math.min(parent.width, col.width*1.5)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: qsTranslate("filter", "To filter by file extension, start the term with a dot. Setting the width or height of the resolution to 0 ignores that dimension.")

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

                PQCheckBox {

                    id: filenamecheck

                    y: (filenameedit.height-height)/2

                    text: qsTranslate("filter", "File name/extension:")

                    onCheckedChanged: {
                        if(checked)
                            filenameedit.setFocus()
                    }
                }

                PQLineEdit {

                    id: filenameedit

                    enabled: filenamecheck.checked&&filter_top.opacity>0

                    width: 300
                    height: 40

                    placeholderText: qsTranslate("filter", "Enter terms")
                }

            }

            Row {

                id: imageresrow

                spacing: 10

                PQCheckBox {
                    id: rescheck
                    y: (reswidth.height-height)/2
                    text: qsTranslate("filter", "Image Resolution")
                    onCheckedChanged: {
                        if(rescheck.checked)
                            reswidth.forceActiveFocus()
                    }
                }

                PQButton {
                    id: resgreaterless
                    y: (filesize.height-height)/2
                    width: height
                    enabled: rescheck.checked
                    property bool greater: true
                    text: greater ? ">" : "<"
                    font.weight: PQCLook.fontWeightBold 
                    font.pointSize: PQCLook.fontSizeL 
                    tooltip: greater ?
                                 //: used as tooltip in the sense of 'image resolution GREATER THAN 123x123'
                                 qsTranslate("filter", "greater than") :
                                 //: used as tooltip in the sense of 'image resolution LESS THAN 123x123'
                                 qsTranslate("filter", "less than")
                    onClicked: {
                        reswidth.forceActiveFocus()
                        greater = !greater
                    }
                }

                PQSliderSpinBox {
                    id: reswidth
                    enabled: rescheck.checked
                    minval: 0
                    maxval: 99999999
                    showSlider: false
                    onEditModeChanged: {
                        if(editMode) {
                            filter_top.countOpenSpin += 1
                            filter_top.closeAllSpinExcept("reswidth")
                        } else
                            filter_top.countOpenSpin -= 1
                    }
                    Connections {
                        target: filter_top
                        function onCloseAllSpinExcept(senderid : string) {
                            if(senderid !== "reswidth")
                                reswidth.acceptValue()
                        }
                    }
                }
                PQText {
                    y: (resheight.height-height)/2
                    enabled: rescheck.checked
                    font.weight: PQCLook.fontWeightBold 
                    text: "x"
                }
                PQSliderSpinBox {
                    id: resheight
                    enabled: rescheck.checked
                    minval: 0
                    maxval: 99999999
                    showSlider: false
                    onEditModeChanged: {
                        if(editMode) {
                            filter_top.countOpenSpin += 1
                            filter_top.closeAllSpinExcept("resheight")
                        } else
                            filter_top.countOpenSpin -= 1
                    }
                    Connections {
                        target: filter_top
                        function onCloseAllSpinExcept(senderid : string) {
                            if(senderid !== "resheight")
                                resheight.acceptValue()
                        }
                    }
                }

            }

            Row {

                id: filesizerow

                spacing: 10

                PQCheckBox {
                    id: filesizecheck
                    y: (filesize.height-height)/2
                    text: qsTranslate("filter", "File size")
                    onCheckedChanged: {
                        if(filesizecheck.checked)
                            filesize.forceActiveFocus()
                    }
                }

                PQButton {
                    id: filesizegreaterless
                    y: (filesize.height-height)/2
                    width: height
                    enabled: filesizecheck.checked
                    property bool greater: true
                    text: greater ? ">" : "<"
                    font.weight: PQCLook.fontWeightBold 
                    font.pointSize: PQCLook.fontSizeL 
                    tooltip: greater ?
                                 //: used as tooltip in the sense of 'file size GREATER THAN 123 KB/MB'
                                 qsTranslate("filter", "greater than") :
                                 //: used as tooltip in the sense of 'file size LESS THAN 123 KB/MB'
                                 qsTranslate("filter", "less than")
                    onClicked: {
                        greater = !greater
                        filesize.forceActiveFocus()
                    }
                }

                PQSliderSpinBox {
                    id: filesize
                    enabled: filesizecheck.checked
                    minval: 0
                    maxval: 99999999
                    showSlider: false
                    onEditModeChanged: {
                        if(editMode) {
                            filter_top.countOpenSpin += 1
                            filter_top.closeAllSpinExcept("filesize")
                        } else
                            filter_top.countOpenSpin -= 1
                    }
                    Connections {
                        target: filter_top
                        function onCloseAllSpinExcept(senderid : string) {
                            if(senderid !== "filesize")
                                filesize.acceptValue()
                        }
                    }
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

                height: rescheck.checked ? infotxt.height : 0
                Behavior on height { NumberAnimation { duration: 250 } }

                clip: true

                PQText {
                    id: infotxt
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    text: qsTranslate("filter", "Please note that filtering by image resolution can take a little while, depending on the number of images in the folder.")

                }

            }

        }

    ]

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === filter_top.thisis)
                    filter_top.show()

            } else if(what === "hide") {

                if(param[0] === filter_top.thisis)
                    filter_top.hide()

            } else if(filter_top.visible) {

                if(what === "removeFilter") {

                    filter_top.button3.clicked()

                } else if(what === "keyEvent") {

                    if(filter_top.closeAnyMenu())
                        return

                    if(param[0] === Qt.Key_Escape) {

                        if(reswidth.editMode || resheight.editMode || filesize.editMode)
                            filter_top.closePopupMenuSpin()
                        else
                            filter_top.button2.clicked()

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        filter_top.button1.clicked()
                    else if(param[0] === Qt.Key_Tab) {
                        if(reswidth.activeFocus)
                            resheight.forceActiveFocus()
                        else if(resheight.activeFocus)
                            reswidth.forceActiveFocus()
                    }

                }
            }
        }
    }

    function closeAnyMenu() {
        if(resgreaterless.contextmenu.visible) {
            resgreaterless.contextmenu.close()
            return true
        } else if(filesizegreaterless.contextmenu.visible) {
            filesizegreaterless.contextmenu.close()
            return true
        } else if(reswidth.contextMenuOpen) {
            reswidth.closeContextMenus()
            return true
        } else if(resheight.contextMenuOpen) {
            resheight.closeContextMenus()
            return true
        } else if(filesize.contextMenuOpen) {
            filesize.closeContextMenus()
            return true
        } else if(filter_top.contextMenuOpen) {
            filter_top.closeContextMenus()
            return true
        }
        return false
    }

    function closePopupMenuSpin() {
        reswidth.acceptValue()
        resheight.acceptValue()
        filesize.acceptValue()
    }

    function show() {
        if((PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) && !PQCFileFolderModel.filterCurrentlyActive) { 
            hide()
            return
        }
        opacity = 1
        if(popoutWindowUsed)
            filter_popout.visible = true

        // we explicitely load the data below to pre-load it even when switching between popout and not

        // load filename filter data
        var txt1 = PQCFileFolderModel.nameFilters.join(" ")
        var txt2 = PQCFileFolderModel.filenameFilters.join(" .")
        if(txt1 !== "") txt1 = "."+txt1

        if(txt1 !== "" || txt2 !== "") {
            filenamecheck.checked = true
            filenameedit.text = txt1 + (txt1==="" ? "" : " ") + txt2
        } else {
            filenamecheck.checked = false
            filenameedit.text = ""
        }

        // load image resolution filter data
        var w = PQCFileFolderModel.imageResolutionFilter.width
        var h = PQCFileFolderModel.imageResolutionFilter.height
        if(w > 0 || h > 0) {
            resgreaterless.greater = true
            rescheck.checked = true
            reswidth.loadAndSetDefault(w)
            resheight.loadAndSetDefault(h)
        } else if(w < 0 || h < 0) {
            resgreaterless.greater = false
            rescheck.checked = true
            reswidth.loadAndSetDefault(-1*w)
            resheight.loadAndSetDefault(-1*h)
        } else {
            resgreaterless.greater = true
            rescheck.checked = false
            reswidth.loadAndSetDefault(0)
            resheight.loadAndSetDefault(0)
        }

        // load file size filter data
        var s = PQCFileFolderModel.fileSizeFilter
        if(s !== 0) {
            filesizecheck.checked = true
            filesizegreaterless.greater = (s > 0)

            if(s < 0) s *= -1

            var mb = Math.round(s/(1024*1024))
            var kb = Math.round(s/1024)
            if(mb*1024*1024 === s) {
                filesizemb.checked = true
                filesize.loadAndSetDefault(mb)
            } else {
                filesizekb.checked = true
                filesize.loadAndSetDefault(kb)
            }

        }

    }

    function hide() {
        closeAnyMenu()
        closePopupMenuSpin()
        filter_top.opacity = 0
        if(popoutWindowUsed && filter_popout.visible)
            filter_popout.visible = false 
        else
            PQCNotify.loaderRegisterClose(thisis)
        fullscreenitem.forceActiveFocus()
    }

    function setFilter() {

        var fileNameFilter = []
        var fileEndingFilter = []

        // filter out search terms and search suffixes
        if(filenamecheck.checked) {
            var spl = filenameedit.text.split(" ")
            for(var iSpl = 0; iSpl < spl.length; ++iSpl) {
                if(spl[iSpl][0] === ".")
                    fileEndingFilter.push(spl[iSpl].slice(1))
                else {
                    fileNameFilter.push(spl[iSpl])
                }
            }
        }
        PQCFileFolderModel.nameFilters = fileEndingFilter 
        PQCFileFolderModel.filenameFilters = fileNameFilter

        if(rescheck.checked)
            PQCFileFolderModel.imageResolutionFilter = Qt.size((resgreaterless.greater ? 1 : -1)*reswidth.value, (resgreaterless.greater ? 1 : -1)*resheight.value)
        else
            PQCFileFolderModel.imageResolutionFilter = Qt.size(0,0)

        if(filesizecheck.checked)
            PQCFileFolderModel.fileSizeFilter = (filesizegreaterless.greater ? 1 : -1)*filesize.value*(filesizekb.checked ? 1024 : (1024*1024))
        else
            PQCFileFolderModel.fileSizeFilter = 0

    }

    function removeFilter() {

        filenamecheck.checked = false
        rescheck.checked = false
        filesizecheck.checked = false

        PQCFileFolderModel.removeAllUserFilter() 

    }

}
