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
import Qt.labs.platform 1.0
import "../../elements"

Menu {

    id: control

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    signal closed()

    function popup() {
        open()
    }

    MenuItem {
        visible: isFile || isFolder
        text: (isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file"))
        onTriggered: {
            if(isFolder)
                filedialog_top.setCurrentDirectory(path)
            else {
                filefoldermodel.setFileNameOnceReloaded = path
                filefoldermodel.fileInFolderMainView = path
                filedialog_top.hideFileDialog()
            }
        }
    }
    MenuItem {
        visible: isFolder
        text: (em.pty+qsTranslate("filedialog", "Add to Favorites"))
        onTriggered:
            handlingFileDialog.addNewUserPlacesEntry(path, upl.model.count)
    }
    MenuSeparator { visible: isFile || isFolder }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileShowHiddenFilesFolders
        text: qsTranslate("filedialog", "Show hidden files")
        onTriggered:
            PQSettings.openfileShowHiddenFilesFolders = !PQSettings.openfileShowHiddenFilesFolders
    }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileThumbnails
        text: qsTranslate("filedialog", "Show thumbnails")
        onTriggered:
            PQSettings.openfileThumbnails = !PQSettings.openfileThumbnails
    }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileDetailsTooltip
        text: qsTranslate("filedialog", "Show tooltip with image details")
        onTriggered:
            PQSettings.openfileDetailsTooltip = !PQSettings.openfileDetailsTooltip
    }
    Menu {
        title: "Preview"
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreview
            //: This is a context menu entry, referring to whether the large preview image is VISIBLE
            text: em.pty+qsTranslate("filedialog", "Visible")
            onTriggered:
                PQSettings.openfilePreview = !PQSettings.openfilePreview
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreviewHigherResolution
            //: This is a context menu entry, referring to whether a preview image with a HIGHER RESOLUTION should be loaded
            text: em.pty+qsTranslate("filedialog", "Higher resolution")
            onTriggered:
                PQSettings.openfilePreviewHigherResolution = !PQSettings.openfilePreviewHigherResolution
        }
        MenuItem {
            checkable: true
            checked: PQSettings.openfilePreviewBlur
            //: This is a context menu entry, selecting it will BLUR the preview IMAGE
            text: em.pty+qsTranslate("filedialog", "Blurred image")
            onTriggered:
                PQSettings.openfilePreviewBlur = !PQSettings.openfilePreviewBlur
        }
        Menu {
            title: em.pty+qsTranslate("filedialog", "Color intensity")
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==10 ? "* " : "") + "100%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 10
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==9 ? "* " : "") + "90%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 9
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==8 ? "* " : "") + "80%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 8
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==7 ? "* " : "") + "70%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 7
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==6 ? "* " : "") + "60%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 6
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==5 ? "* " : "") + "50%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 5
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==4 ? "* " : "") + "40%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 4
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==3 ? "* " : "") + "30%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 3
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==2 ? "* " : "") + "20%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 2
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==1 ? "* " : "") + "10%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 1
            }
            MenuItem {
                text: (PQSettings.openfilePreviewColorIntensity==0 ? "* " : "") + "0%"
                onTriggered:
                    PQSettings.openfilePreviewColorIntensity = 0
            }
        }
    }

    Connections {
        target: PQKeyPressMouseChecker
        onReceivedMouseButtonPress:
            control.close()
    }

}
