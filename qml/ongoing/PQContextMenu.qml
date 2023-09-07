import QtQuick

import PQCNotify
import PQCScriptsShortcuts
import PQCFileFolderModel
import PQCScriptsContextMenu

import "../elements"

PQMenu {

    PQMenuItem {
        iconSource: "/white/rename.svg"
        text: qsTranslate("contextmenu", "Rename file")
        onClicked:
            console.log("rename")
    }

    PQMenuItem {
        iconSource: "/white/copy.svg"
        text: qsTranslate("contextmenu", "Copy file")
        onClicked:
            console.log("copy")
    }

    PQMenuItem {
        iconSource: "/white/move.svg"
        text: qsTranslate("contextmenu", "Move file")
        onClicked:
            console.log("move")
    }

    PQMenuItem {
        iconSource: "/white/delete.svg"
        text: qsTranslate("contextmenu", "Delete file")
        onClicked:
            console.log("delete")
    }

    PQMenuSeparator {}

    PQMenuItem {
        iconSource: "/white/clipboard.svg"
        text: qsTranslate("contextmenu", "Copy to clipboard")
    }

    PQMenuItem {
        iconSource: "/white/convert.svg"
        text: qsTranslate("contextmenu", "Export to different format")
        onClicked:
            PQCNotify.executeInternalCommand("__export")
    }

    PQMenuItem {
        iconSource: "/white/scale.svg"
        text: qsTranslate("contextmenu", "Scale image")
    }

    PQMenuItem {
        iconSource: "/white/faces.svg"
        text: qsTranslate("contextmenu", "Tag faces")
    }

    PQMenuItem {
        iconSource: "/white/wallpaper.svg"
        text: qsTranslate("contextmenu", "Set as wallpaper")
    }

    PQMenuSeparator {}

    PQMenuItem {
        iconSource: "/white/histogram.svg"
        text: qsTranslate("contextmenu", "Show histogram")
        onClicked:
            PQCNotify.executeInternalCommand("__histogram")
    }

    PQMenuItem {
        iconSource: "/white/mapmarker.svg"
        text: qsTranslate("contextmenu", "Show on map")
        onClicked:
            PQCNotify.executeInternalCommand("__showMapCurrent")
    }

    PQMenuSeparator {}

    property var ext: PQCScriptsContextMenu.getEntries()

    Repeater {
        model: ext.length

        PQMenuItem {
            property var entry: ext[index]
            iconSource: entry[0]
            text: entry[2]
            onTriggered: {
                if(entry[1].startsWith("__"))
                    PQCNotify.executeInternalCommand(entry[1])
                else
                    PQCScriptsShortcuts.executeExternal(entry[1], entry[4], PQCFileFolderModel.currentFile)
            }
        }

    }


}
