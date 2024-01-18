/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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
import QtQuick.Controls

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsShortcuts
import PQCScriptsConfig
import PQCScriptsFileManagement
import PQCWindowGeometry

import "../elements"

PQTemplateFullscreen {

    id: delete_top

    thisis: "filedelete"
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
            color: PQCLook.textColorHighlight
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
            text: "<table><tr><td align=right>" + shortcuts.item.translateShortcut("Enter") +
                  "</td><td>=</td><td>" + qsTranslate("filemanagement", "Move to trash") +
                  "</td</tr><tr><td align=right>" + shortcuts.item.translateShortcut("Shift+Enter") +
                  "</td><td>=</td><td>" + qsTranslate("filemanagement", "Delete permanently") + "</td></tr></table>"
        }

    ]

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(delete_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        hide()

                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(param[1] & Qt.ShiftModifier)
                            deletePermanently()
                        else
                            moveToTrash()

                    }
                }
            }
        }
    }

    function moveToTrash() {

        if(!PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
            error.visible = true
            return
        }

        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        hide()

    }

    function deletePermanently() {

        if(!PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.currentFile)) {
            error.visible = true
            return
        }

        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        hide()

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }
        opacity = 1
        error.visible = false
        filename.text = PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)

        if(popout)
            filedelete_popout.show()

    }

    function hide() {
        delete_top.opacity = 0
        loader.elementClosed(thisis)
    }

}
