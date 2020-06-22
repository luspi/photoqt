import QtQuick 2.9
import QtQuick.Controls 2.2

import "./thumbnails"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent
        anchors.margins: 10

        Rectangle {

            x: 278
            y: title.height+desc.height+30
            width: 2
            height: cont.contentHeight-y
            color: "#88444444"

        }

        Column {

            id: col

            spacing: 15

            Text {
                id: title
                width: cont.width
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: "Thumbnails settings"
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings affect the thumbnails shown, by default, along the bottom edge of the screen. This includes their look, behavior, and the user's interaction with them.\nSome settings are only shown in expert mode."
            }

            PQCache { id: cac }
                PQHorizontalLine { expertModeOnly: cac.expertmodeonly }
            PQCenter { id: cent }
                PQHorizontalLine { expertModeOnly: cent.expertmodeonly }
            PQDisable { id: dis }
                PQHorizontalLine { expertModeOnly: dis.expertmodeonly }
            PQFilenameLabel { id: fnl }
                PQHorizontalLine { expertModeOnly: fnl.expertmodeonly }
            PQFilenameOnly { id: fno }
                PQHorizontalLine { expertModeOnly: fno.expertmodeonly }
            PQLiftUp { id: lft }
                PQHorizontalLine { expertModeOnly: lft.expertmodeonly }
            PQPosition { id: pos }
                PQHorizontalLine { expertModeOnly: pos.expertmodeonly }
            PQSize { id: siz }
                PQHorizontalLine { expertModeOnly: siz.expertmodeonly }
            PQSpacing { id: spc }
                PQHorizontalLine { expertModeOnly: spc.expertmodeonly }
            PQThreads { id: thr }
                PQHorizontalLine { expertModeOnly: thr.expertmodeonly }
            PQVisible { id: vis }

        }

    }

}
