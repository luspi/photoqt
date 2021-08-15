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

Item {

    Connections {

        target: PQPassOn

        onCmdFilePath: {

            if(handlingFileDir.doesItExist(path)) {

                // first we close any element that might be open to show the new image

                closeAllExcept("")

                // compare old and new folder to see if that changed
                var folderOld = (filefoldermodel.countMainView == 0 ? "" : handlingFileDir.getFilePathFromFullPath(filefoldermodel.entriesMainView[0]))
                var folderNew = handlingFileDir.getFilePathFromFullPath(path)

                // load new folder and image
                if(folderNew != folderOld) {
                    filefoldermodel.setFileNameOnceReloaded = path
                    filefoldermodel.fileInFolderMainView = path
                } else
                    filefoldermodel.setAsCurrent(handlingFileDir.cleanPath(path))

            } else
                console.log("ERROR: File does not exist:", path)

            toplevel.raise()

        }

        onCmdOpen: {
            closeAllExcept("filedialog")
            if(variables.visibleItem == "")
                loader.show("filedialog")
            toplevel.raise()
        }

        onCmdShow: {
            toplevel.visible = true
            toplevel.raise()
        }

        onCmdHide: {
            PQSettings.trayIcon = 1
            toplevel.visible = false
        }

        onCmdToggle: {
            PQSettings.trayIcon = 1
            toplevel.visible = !toplevel.visible
            if(toplevel.visible)
                toplevel.raise()
        }

        onCmdThumbs: {
            PQSettings.thumbnailDisable = !thb
        }

        onCmdShortcutSequence: {
            PQKeyPressMouseChecker.simulateKeyPress(seq)
        }

        onCmdTray: {
            if(tray)
                PQSettings.trayIcon = 1
            else {
                if(!toplevel.visible)
                    toplevel.visible = true
                PQSettings.trayIcon = 0
            }
        }

        Component.onCompleted: {

            // check at startup

            // --thumbs / --no-thumbs
            if(PQPassOn.getThumbs() != 2)
                PQSettings.thumbnailDisable = !PQPassOn.getThumbs()

            // --start-in-tray
            if(PQPassOn.getStartInTray()) {
                PQSettings.trayIcon = 1
                toplevel.visible = false
            }

        }

    }

    function closeAllExcept(exclude) {

        if(variables.visibleItem == "filedialog" && exclude != "filedialog")
            loader.passOn("filedialog", "hide", undefined)

        else if(variables.visibleItem == "slideshowsettings" && exclude != "slideshowsettings")
            loader.passOn("slideshowsettings", "hide", undefined)

        else if(variables.visibleItem == "slideshowcontrols" && exclude != "slideshowcontrols")
            loader.passOn("slideshowcontrols", "quit", undefined)

        else if(variables.visibleItem == "filedelete" && exclude != "filedelete")
            loader.passOn("filedelete", "hide", undefined)

        else if(variables.visibleItem == "filerename" && exclude != "filerename")
            loader.passOn("filerename", "hide", undefined)

        else if(variables.visibleItem == "scale" && exclude != "scale")
            loader.passOn("scale", "hide", undefined)

        else if(variables.visibleItem == "about" && exclude != "about")
            loader.passOn("about", "hide", undefined)

        else if(variables.visibleItem == "imgur" && exclude != "imgur")
            loader.passOn("imgur", "hide", undefined)

        else if(variables.visibleItem == "wallpaper" && exclude != "wallpaper")
            loader.passOn("wallpaper", "hide", undefined)

        else if(variables.visibleItem == "settingsmanager" && exclude != "settingsmanager")
            loader.passOn("settingsmanager", "hide", undefined)

        else if(variables.visibleItem == "filter" && exclude != "filter")
            loader.passOn("filter", "hide", undefined)

        else if(variables.visibleItem == "facetagger" && exclude != "facetagger")
            loader.passOn("facetagger", "stop", undefined)

        else if(variables.visibleItem == "unavailable" && exclude != "unavailable")
            loader.passOn("unavailable", "hide", undefined)

    }

}
