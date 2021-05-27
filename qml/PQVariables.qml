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
import "shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    property var shortcuts: []
    property string visibleItem: ""
    property real currentZoomLevel: 1
    property real currentRotationAngle: 0
    property real currentPaintedZoomLevel: 1
    property string openCurrentDirectory: PQSettings.openKeepLastLocation ? handlingFileDialog.getLastLocation() : handlingFileDir.getHomeDir()
    property point mousePos: Qt.point(-1, -1)
    property int metaDataWidthWhenKeptOpen: 0

    property bool slideShowActive: false
    property bool faceTaggingActive: false

    property var zoomRotationMirror: ({})

    property bool settingsManagerExpertMode: false

    property bool videoControlsVisible: false

    Component.onCompleted: {
        // this is to break the property binding of this variable
        // if we don't do this then turning the 'remember' property off in the file dialog might load the home directory
        openCurrentDirectory = openCurrentDirectory
    }

    onOpenCurrentDirectoryChanged:
        handlingFileDialog.setLastLocation(openCurrentDirectory)


    Connections {
        target: PQCppVariables

        onCmdFilePathChanged: {

            if(PQCppVariables.cmdFilePath != "") {

                var folderOld = (filefoldermodel.countMainView == 0 ? "" : handlingFileDir.getFilePathFromFullPath(filefoldermodel.getFilePathMainView(0)))
                var folderNew = handlingFileDir.getFilePathFromFullPath(PQCppVariables.cmdFilePath)

                if(folderNew != folderOld)
                    filefoldermodel.fileInFolderMainView = folderNew
                filefoldermodel.setAsCurrent(handlingFileDir.cleanPath(PQCppVariables.cmdFilePath))

                // reset variable
                PQCppVariables.cmdFilePath = ""
            }

        }

        onCmdOpenChanged: {
            if(PQCppVariables.cmdOpen) {

                if(variables.visibleItem != "filedialog")
                    loader.show("filedialog")

                PQCppVariables.cmdOpen = false
            }
        }

        onCmdShowChanged: {
            if(PQCppVariables.cmdShow) {
                console.log("show")
                PQCppVariables.cmdShow = false
            }
        }

        onCmdHideChanged: {
            if(PQCppVariables.cmdHide) {
                console.log("hide")
                PQCppVariables.cmdHide = false
            }
        }

        onCmdToggleChanged: {
            if(PQCppVariables.cmdToggle) {
                console.log("toggle")
                PQCppVariables.cmdToggle = false
            }
        }

        onCmdThumbsChanged: {
            if(PQCppVariables.cmdThumbs) {
                console.log("thumbs")
                PQCppVariables.cmdThumbs = false
            }
        }

        onCmdShortcutSequenceChanged: {
            if(PQCppVariables.cmdShortcutSequence != "") {
                HandleShortcuts.checkComboForShortcut(PQCppVariables.cmdShortcutSequence)
                PQCppVariables.cmdShortcutSequence = ""
            }
        }

        onCmdNoThumbsChanged: {
            if(PQCppVariables.cmdNoThumbs) {
                console.log("nothumbs")
                PQCppVariables.cmdNoThumbs = false
            }
        }

        onCmdTrayChanged: {
            if(PQCppVariables.cmdTray) {
                console.log("tray")
                PQCppVariables.cmdTray = false
            }
        }

//        onCmdDebugChanged: {
            // this we actually do not handle here
            // if this changes to true, we keep it at true and use it to detect debug modus everywhere
//        }

    }

    Connections {

        target: PQSettings

        onMainMenuPopoutElementChanged:
            loader.ensureItIsReady("mainmenu")

        onMetadataPopoutElementChanged:
            loader.ensureItIsReady("metadata")

        onHistogramPopoutElementChanged:
            loader.ensureItIsReady("histogram")

        onSlideShowSettingsPopoutElementChanged: {
            if(variables.visibleItem == "slideshowsettings") {
                loader.ensureItIsReady("slideshowsettings")
                loader.show("slideshowsettings")
            }
        }

    }

}
