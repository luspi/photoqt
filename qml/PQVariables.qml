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

    Connections {
        target: PQCppVariables

        onCmdFilePathChanged: {

            if(PQCppVariables.cmdFilePath != "") {

                // first we close any element that might be open to show the new image

                if(variables.visibleItem == "filedialog")
                    loader.passOn("filedialog", "hide", undefined)

                else if(variables.visibleItem == "slideshowsettings")
                    loader.passOn("slideshowsettings", "hide", undefined)

                else if(variables.visibleItem == "slideshowcontrols")
                    loader.passOn("slideshowcontrols", "quit", undefined)

                else if(variables.visibleItem == "filedelete")
                    loader.passOn("filedelete", "hide", undefined)

                else if(variables.visibleItem == "filerename")
                    loader.passOn("filerename", "hide", undefined)

                else if(variables.visibleItem == "scale")
                    loader.passOn("scale", "hide", undefined)

                else if(variables.visibleItem == "about")
                    loader.passOn("about", "hide", undefined)

                else if(variables.visibleItem == "imgur")
                    loader.passOn("imgur", "hide", undefined)

                else if(variables.visibleItem == "wallpaper")
                    loader.passOn("wallpaper", "hide", undefined)

                else if(variables.visibleItem == "settingsmanager")
                    loader.passOn("settingsmanager", "hide", undefined)

                else if(variables.visibleItem == "filter")
                    loader.passOn("filter", "hide", undefined)

                else if(variables.visibleItem == "facetagger")
                    loader.passOn("facetagger", "stop", undefined)

                // compare old and new folder to see if that changed
                var folderOld = (filefoldermodel.countMainView == 0 ? "" : handlingFileDir.getFilePathFromFullPath(filefoldermodel.entriesMainView[0]))
                var folderNew = handlingFileDir.getFilePathFromFullPath(PQCppVariables.cmdFilePath)

                // load new folder and image
                if(folderNew != folderOld) {
                    filefoldermodel.setFileNameOnceReloaded = PQCppVariables.cmdFilePath
                    filefoldermodel.fileInFolderMainView = PQCppVariables.cmdFilePath
                } else
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
                toplevel.visible = true
                PQCppVariables.cmdShow = false
            }
        }

        onCmdHideChanged: {
            if(PQCppVariables.cmdHide) {
                PQSettings.trayIcon = 1
                toplevel.visible = false
                PQCppVariables.cmdHide = false
            }
        }

        onCmdToggleChanged: {
            if(PQCppVariables.cmdToggle) {
                PQSettings.trayIcon = 1
                toplevel.visible = !toplevel.visible
                PQCppVariables.cmdToggle = false
            }
        }

        onCmdThumbsChanged: {
            if(PQCppVariables.cmdThumbs) {
                PQSettings.thumbnailDisable = false
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
                PQSettings.thumbnailDisable = true
                PQCppVariables.cmdNoThumbs = false
            }
        }

        onCmdTrayChanged: {
            if(PQCppVariables.cmdTray) {
                PQSettings.trayIcon = 1
                toplevel.visible = false
                PQCppVariables.cmdTray = false
            }
        }

        Component.onCompleted: {
            PQCppVariables.cmdThumbsChanged()
            PQCppVariables.cmdNoThumbsChanged()
            PQCppVariables.cmdTrayChanged()
        }

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
