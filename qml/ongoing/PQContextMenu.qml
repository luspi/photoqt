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

import PQCNotify
import PQCScriptsShortcuts
import PQCFileFolderModel
import PQCScriptsContextMenu
import PQCScriptsConfig

import "../elements"

PQMenu {

    id: menutop

    PQMenuItem {
        iconSource: "image://svg/:/white/rename.svg"
        text: qsTranslate("contextmenu", "Rename file")
        onClicked:
            PQCNotify.executeInternalCommand("__rename")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/copy.svg"
        text: qsTranslate("contextmenu", "Copy file")
        onClicked:
            PQCNotify.executeInternalCommand("__copy")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/move.svg"
        text: qsTranslate("contextmenu", "Move file")
        onClicked:
            PQCNotify.executeInternalCommand("__move")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/delete.svg"
        text: qsTranslate("contextmenu", "Delete file")
        onClicked:
            PQCNotify.executeInternalCommand("__deleteTrash")
    }

    PQMenuSeparator {}

    PQMenuItem {
        iconSource: "image://svg/:/white/clipboard.svg"
        text: qsTranslate("contextmenu", "Copy to clipboard")
        onClicked:
            PQCNotify.executeInternalCommand("__clipboard")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/convert.svg"
        text: qsTranslate("contextmenu", "Export to different format")
        onClicked:
            PQCNotify.executeInternalCommand("__export")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/scale.svg"
        text: qsTranslate("contextmenu", "Scale image")
        onClicked:
            PQCNotify.executeInternalCommand("__scale")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/faces.svg"
        text: qsTranslate("contextmenu", "Tag faces")
        onClicked:
            PQCNotify.executeInternalCommand("__tagFaces")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/wallpaper.svg"
        text: qsTranslate("contextmenu", "Set as wallpaper")
        onClicked:
            PQCNotify.executeInternalCommand("__wallpaper")
    }

    PQMenuSeparator {}

    PQMenuItem {
        iconSource: "image://svg/:/white/histogram.svg"
        text: qsTranslate("contextmenu", "Show histogram")
        onClicked:
            PQCNotify.executeInternalCommand("__histogram")
    }

    Repeater {
        model: PQCScriptsConfig.isLocationSupportEnabled() ? 1 : 0
        PQMenuItem {
            iconSource: "image://svg/:/white/mapmarker.svg"
            text: qsTranslate("contextmenu", "Show on map")
            onClicked:
                PQCNotify.executeInternalCommand("__showMapCurrent")
        }
    }

    Repeater {
        model: PQCScriptsConfig.isZXingSupportEnabled() ? 1 : 0
        PQMenuItem {
            iconSource: "image://svg/:/white/qrcode.svg"
            text: PQCNotify.barcodeDisplayed ? qsTranslate("contextmenu", "Hide QR/barcodes") : qsTranslate("contextmenu", "Detect QR/barcodes")
            onClicked:
                PQCNotify.executeInternalCommand("__detectBarCodes")
        }
    }

    PQMenuSeparator { visible: customentries.length>0 }

    property var customentries: PQCScriptsContextMenu.getEntries()

    Repeater {

        model: customentries.length

        PQMenuItem {
            property var entry: customentries[index]
            iconSource: entry[0]==="" ? "image://svg/:/white/application.svg" : ("data:image/png;base64," + entry[0])
            text: entry[2]
            onTriggered: {
                if(entry[1].startsWith("__"))
                    PQCNotify.executeInternalCommand(entry[1])
                else
                    PQCScriptsShortcuts.executeExternal(entry[1], entry[4], PQCFileFolderModel.currentFile)
            }
        }

    }

    Connections {
        target: PQCScriptsContextMenu
        function onCustomEntriesChanged() {
            customentries = PQCScriptsContextMenu.getEntries()
        }
    }

}
