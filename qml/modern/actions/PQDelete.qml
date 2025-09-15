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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

PQTemplateFullscreen {

    id: delete_top

    thisis: "FileDelete"
    popout: PQCSettings.interfacePopoutFileDelete 
    forcePopout: PQCWindowGeometry.filedeleteForcePopout 
    shortcut: "__delete"

    title: qsTranslate("filemanagement", "Delete file?")

    button1.text: qsTranslate("filemanagement", "Move to trash")

    button2.visible: true
    button2.font.pointSize: PQCLook.fontSize 
    button2.text: qsTranslate("filemanagement", "Delete permanently")
    button2.font.weight: PQCLook.fontWeightNormal 

    button3.visible: true
    button3.font.pointSize: PQCLook.fontSize 
    button3.text: genericStringCancel
    button3.font.weight: PQCLook.fontWeightNormal 

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled }

    onPopoutChanged:
        PQCSettings.interfacePopoutFileDelete = popout 

    button1.onClicked:
        moveToTrash()

    button2.onClicked:
        deletePermanently()

    button3.onClicked:
        hide()

    content: [

        PQTextXL {
            id: heading
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold 
            text: qsTranslate("filemanagement", "Are you sure you want to delete this file?")
        },

        PQTextL {
            id: filename
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            color: pqtPaletteDisabled.text
            text: "this_is_the_filename.jpg"
        },

        PQTextL {
            id: error
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold 
            visible: false
            text: qsTranslate("filemanagement", "An error occured, file could not be deleted!")
        },

        Item {
            width: 1
            height: 1
        },

        PQText {
            x: (parent.width-width)/2
            font.weight: PQCLook.fontWeightBold 
            textFormat: Text.RichText
            text: "<table><tr><td align=right>" + PQCScriptsShortcuts.translateShortcut("Enter") + 
                  "</td><td>=</td><td>" + qsTranslate("filemanagement", "Move to trash") +
                  "</td</tr><tr><td align=right>" + PQCScriptsShortcuts.translateShortcut("Shift+Enter") +
                  "</td><td>=</td><td>" + qsTranslate("filemanagement", "Delete permanently") + "</td></tr></table>"
        }

    ]

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === delete_top.thisis)
                    delete_top.show()

            } else if(what === "hide") {

                if(param[0] === delete_top.thisis)
                    delete_top.hide()

            } else if(delete_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(delete_top.contextMenuOpen) {
                        delete_top.closeContextMenus()
                        return
                    }

                    if(param[0] === Qt.Key_Escape)
                        delete_top.hide()

                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(param[1] & Qt.ShiftModifier)
                            delete_top.deletePermanently()
                        else
                            delete_top.moveToTrash()

                    }
                }
            }
        }
    }

    function moveToTrash() {

        PQCConstants.ignoreFileFolderChangesTemporary = true

        if(!PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) { 
            error.visible = true
            PQCConstants.ignoreFileFolderChangesTemporary = false
            return
        }

        PQCConstants.ignoreFileFolderChangesTemporary = false
        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        hide()

    }

    function deletePermanently() {

        PQCConstants.ignoreFileFolderChangesTemporary = true

        if(!PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.currentFile)) { 
            error.visible = true
            PQCConstants.ignoreFileFolderChangesTemporary = false
            return
        }

        PQCConstants.ignoreFileFolderChangesTemporary = false
        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        hide()

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { 
            hide()
            return
        }
        opacity = 1
        if(popoutWindowUsed)
            filedelete_popout.visible = true
        error.visible = false
        filename.text = PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)

    }

    function hide() {

        if(delete_top.contextMenuOpen)
            delete_top.closeContextMenus()

        delete_top.opacity = 0
        if(popoutWindowUsed && filedelete_popout.visible)
            filedelete_popout.visible = false 
        else
            PQCNotify.loaderRegisterClose(thisis)
    }

}
