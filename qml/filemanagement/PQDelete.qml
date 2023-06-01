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

    id: delete_top

    popout: PQSettings.interfacePopoutFileDelete
    shortcut: "__delete"
    title: "Delete file?"

    buttonFirstText: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutFileDelete = popout

    onButtonFirstClicked:
        close()

    content: [

        PQTextXL {
            id: heading
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            font.weight: baselook.boldweight
            text: em.pty+qsTranslate("filemanagement", "Are you sure you want to delete this file?")
        },

        PQTextL {
            id: filename
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            color: "grey"
            text: "this_is_the_filename.jpg"
        },

        PQTextL {
            id: error
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            color: "red"
            visible: false
            text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be deleted!")
        },

        Item {

            id: butcont

            x: 0
            width: parent.width
            height: childrenRect.height

            Column {

                spacing: 10

                x: (parent.width-width)/2

                Item {
                    width: 1
                    height: 1
                }

                PQButton {
                    id: button_trash
                    x: (parent.width-width)/2
                    visible: !handlingGeneral.amIOnWindows() || handlingGeneral.isAtLeastQt515()
                    scale: 1.2
                    text: em.pty+qsTranslate("filemanagement", "Move to trash")
                    font.weight: baselook.boldweight
                    onClicked: {

                        if(!handlingFileDir.deleteFile(filefoldermodel.currentFilePath, false)) {
                            error.visible = true
                            return
                        }

                        filefoldermodel.removeEntryMainView(filefoldermodel.current)

                        delete_top.close()
                    }
                }
                PQButton {
                    id: button_permanent
                    x: (parent.width-width)/2
                    text: em.pty+qsTranslate("filemanagement", "Delete permanently")
                    scale: button_trash.visible ? 0.8 : 1.2
                    onClicked: {

                        if(!handlingFileDir.deleteFile(filefoldermodel.currentFilePath, true)) {
                            error.visible = true
                            return
                        }

                        filefoldermodel.removeEntryMainView(filefoldermodel.current)

                        delete_top.close()
                    }
                }

            }

        },

        Item {
            width: 1
            height: 1
        },

        PQTextS {
            x: (parent.width-width)/2
            font.weight: baselook.boldweight
            textFormat: Text.RichText
            text: "<table><tr><td align=right>" + keymousestrings.translateShortcut("Enter") +
                  ((!handlingGeneral.amIOnWindows() || handlingGeneral.isAtLeastQt515())
                        ? ("</td><td>=</td><td>" + em.pty+qsTranslate("filemanagement", "Move to trash") +
                          "</td</tr><tr><td align=right>" + keymousestrings.translateShortcut("Shift+Enter"))
                        : "") +
                  "</td><td>=</td><td>" + em.pty+qsTranslate("filemanagement", "Delete permanently") + "</td></tr></table>"
        }

    ]

    Connections {
        target: loader
        onFileDeletePassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1)
                    return
                opacity = 1
                error.visible = false
                variables.visibleItem = "filedelete"
                filename.text = handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath)
            } else if(what == "hide") {
                delete_top.close()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    delete_top.close()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return) {
                    if(param[1] & Qt.ShiftModifier)
                        button_permanent.clicked()
                    else
                        button_trash.clicked()
                }
            }
        }
    }

    function close() {
        delete_top.opacity = 0
        variables.visibleItem = ""
    }

}
