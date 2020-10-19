import QtQuick 2.9
import QtQuick.Controls 2.2

import "./filetypes"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Column {

            id: col

            x: 10
            y: 0

            spacing: 15

            Text {
                id: title
                width: cont.width-20
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: em.pty+qsTranslate("settingsmanager", "Filetype settings")
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings govern which file types PhotoQt should recognize and open.") + "\n" + em.pty+qsTranslate("settingsmanager", "Not all file types might be available, depending on your setup and what library support was enabled at compile time")
            }

            Flow {

                width: cont.width-25
                spacing: 10

                PQFileTypeTileQt {}
                PQFileTypeTileGm {}
                PQFileTypeTileLibRaw {}
                PQFileTypeTileLibArchive {}
                PQFileTypeTileDevil {}
                PQFileTypeTileFreeImage {}
                PQFileTypeTilePoppler {}
                PQFileTypeTileXCF {}
                PQFileTypeTileVideo {}

            }

        }

    }

}
