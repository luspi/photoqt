import QtQuick 2.9
import QtQuick.Controls 2.2

import "./imageview"
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
                text: "Interface settings"
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: "These settings affect the viewing of images, how they are shown, in what order, how large a cache to use, etc.\nSome settings are only shown in expert mode."
            }

            PQSort { id: srt }
                PQHorizontalLine { expertModeOnly: srt.expertmodeonly }
            PQTransparencyMarker { id: trn }
                PQHorizontalLine { expertModeOnly: trn.expertmodeonly }
            PQFitInWindow { id: fiw }
                PQHorizontalLine { expertModeOnly: fiw.expertmodeonly }
            PQLoop { id: loo }
                PQHorizontalLine { expertModeOnly: loo.expertmodeonly }
            PQLeftButton { id: lfb }
                PQHorizontalLine { expertModeOnly: lfb.expertmodeonly }
            PQMargin { id: mrg }
                PQHorizontalLine { expertModeOnly: mrg.expertmodeonly }
            PQPixmapCache { id: pix }
                PQHorizontalLine { expertModeOnly: pix.expertmodeonly }
            PQAnimation { id: ani }
                PQHorizontalLine { expertModeOnly: ani.expertmodeonly }
            PQInterpolation { id: itp }
                PQHorizontalLine { expertModeOnly: itp.expertmodeonly }
            PQKeep { id: kee }
                PQHorizontalLine { expertModeOnly: kee.expertmodeonly }
            PQZoomSpeed { id: zos }

        }

    }

}
