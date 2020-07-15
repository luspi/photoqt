import QtQuick 2.9
import QtQuick.Controls 2.2

import "./thumbnails"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        Rectangle {

            x: 278
            y: title.height+desc.height+30
            width: 2
            height: cont.contentHeight-y
            color: "#88444444"

        }

        Column {

            id: col

            x: 10

            spacing: 15

            Text {
                id: title
                width: cont.width-20
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
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: "These settings affect the thumbnails shown, by default, along the bottom edge of the screen. This includes their look, behavior, and the user's interaction with them.\nSome settings are only shown in expert mode."
            }

            PQSize { id: siz }
                PQHorizontalLine { expertModeOnly: siz.expertmodeonly }
            PQSpacing { id: spc }
                PQHorizontalLine { expertModeOnly: spc.expertmodeonly }
            PQLiftUp { id: lft }
                PQHorizontalLine { expertModeOnly: lft.expertmodeonly }
            PQVisible { id: vis }
                PQHorizontalLine { expertModeOnly: thr.expertmodeonly }
            PQCenter { id: cent }
                PQHorizontalLine { expertModeOnly: cent.expertmodeonly }
            PQPosition { id: pos }
                PQHorizontalLine { expertModeOnly: pos.expertmodeonly }
            PQFilenameLabel { id: fnl }
                PQHorizontalLine { expertModeOnly: fnl.expertmodeonly }
            PQFilenameOnly { id: fno }
                PQHorizontalLine { expertModeOnly: fno.expertmodeonly }
            PQDisable { id: dis }
                PQHorizontalLine { expertModeOnly: dis.expertmodeonly }
            PQCache { id: cac }
                PQHorizontalLine { expertModeOnly: cac.expertmodeonly }
            PQThreads { id: thr }

        }

    }

}
