import QtQuick 2.9
import QtQuick.Controls 2.2

import "./filetypes"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent
        anchors.margins: 10

        Column {

            id: col

            x: 0
            y: 0

            spacing: 15

            Text {
                id: title
                width: cont.width
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: "Filetype settings"
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings govern which file types PhotoQt should recognize and open.\nNot all file types might be available below, depending on your setup and what library support was enabled at compile time"
            }

            Flow {

                width: cont.width
                spacing: 10

                PQFileTypeTileQt {}
                PQFileTypeTileGm {}
                PQFileTypeTileLibRaw {}
                PQFileTypeTileLibArchive {}
                PQFileTypeTileDevil {}
                PQFileTypeTileFreeImage {}
                PQFileTypeTilePoppler {}
                PQFileTypeTileXCF {}

            }

        }

    }

}
