import QtQuick 2.9
import QtQuick.Controls 2.2

import "./thumbnails"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent
        anchors.margins: 10

        Column {

            id: col

            spacing: 25

            Text {
                width: cont.width
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: "Thumbnails settings"
            }

            Text {
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings affect the thumbnails shown, by default, along the bottom edge of the screen. This includes their look, behavior, and the user's interaction with them.\nSome settings are only shown in expert mode."
            }

            PQCache {}
            PQCenter {}
            PQDisable {}
            PQFilenameLabel {}
            PQFilenameOnly {}
            PQLiftUp {}
            PQPosition {}
            PQSize {}
            PQSpacing {}
            PQThreads {}
            PQVisible {}

        }

    }

}
