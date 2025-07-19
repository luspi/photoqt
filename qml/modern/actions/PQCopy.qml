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
import PQCImageFormats
import PhotoQt

Item {

    width: PQCConstants.windowWidth // qmllint disable unqualified
    height: PQCConstants.windowHeight // qmllint disable unqualified

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === "filecopy") {

                    error.opacity = 0
                    if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
                        PQCNotify.loaderRegisterClose("filecopy")
                        return
                    }

                    var targetfile = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("filemanagement", "Copy here"), PQCFileFolderModel.currentFile, PQCImageFormats.detectFormatId(PQCFileFolderModel.currentFile), true);
                    if(targetfile === "") {
                        PQCNotify.loaderRegisterClose("filecopy")
                    } else {
                        if(!PQCScriptsFileManagement.copyFile(PQCFileFolderModel.currentFile, targetfile))
                            error.opacity = 1
                        else
                            PQCNotify.loaderRegisterClose("filecopy")
                    }

                }

            } else if(error.visible) {
                if(what === "keyEvent") {

                    if(errorbutton.contextmenu.visible) {
                        errorbutton.contextmenu.close()
                        return
                    }

                    if(param[0] === Qt.Key_Escape || param[0] === Qt.Key_Return || param[0] === Qt.Key_Enter) {
                        error.opacity = 0
                        PQCNotify.loaderRegisterClose("filecopy")
                    }
                }
            }
        }
    }

    Rectangle {
        id: error
        anchors.fill: parent
        color: PQCLook.baseColor // qmllint disable unqualified
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0
        Column {
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            spacing: 20
            PQTextXXL {
                x: (parent.width-width)/2
                text: qsTranslate("filemanagement", "An error occured")
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
            }
            PQTextL {
                x: (parent.width-width)/2
                text: qsTranslate("filemanagement", "File could not be copied")
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
            }
            PQButton {
                id: errorbutton
                x: (parent.width-width)/2
                text: genericStringClose
                onClicked: {
                    error.opacity = 0
                    PQCNotify.loaderRegisterClose("filecopy") // qmllint disable unqualified
                }
            }
        }
    }

}
