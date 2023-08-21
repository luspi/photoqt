import QtQuick

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
        text: qsTranslate("contextmenu", "Convert to different format")
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
    }

    PQMenuItem {
        iconSource: "/white/mapmarker.svg"
        text: qsTranslate("contextmenu", "Show on map")
    }

    PQMenuSeparator {}

    property var ext: PQCScriptsContextMenu.getEntries()

    Repeater {
        model: ext.length

        PQMenuItem {
            property var entry: ext[index]
            iconSource: entry[0]
            text: entry[2]
        }

    }


}
