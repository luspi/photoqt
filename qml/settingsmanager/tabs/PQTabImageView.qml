import QtQuick 2.9
import QtQuick.Controls 2.2

import "./imageview"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent
        anchors.margins: 10

        Column {

            id: col

            spacing: 15

            Text {
                width: cont.width
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 25
                font.bold: true
                color: "white"
                text: "Interface settings"
            }

            Text {
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings affect the viewing of images, how they are shown, in what order, how large a cache to use, etc.\nSome settings are only shown in expert mode."
            }

            PQAnimation { id: ani }
                PQHorizontalLine { expertModeOnly: ani.expertmodeonly }
            PQFitInWindow { id: fiw }
                PQHorizontalLine { expertModeOnly: fiw.expertmodeonly }
            PQInterpolation { id: itp }
                PQHorizontalLine { expertModeOnly: itp.expertmodeonly }
            PQKeep { id: kee }
                PQHorizontalLine { expertModeOnly: kee.expertmodeonly }
            PQLeftButton { id: lfb }
                PQHorizontalLine { expertModeOnly: lfb.expertmodeonly }
            PQLoop { id: loo }
                PQHorizontalLine { expertModeOnly: loo.expertmodeonly }
            PQMargin { id: mrg }
                PQHorizontalLine { expertModeOnly: mrg.expertmodeonly }
            PQPixmapCache { id: pix }
                PQHorizontalLine { expertModeOnly: pix.expertmodeonly }
            PQSort { id: srt }
                PQHorizontalLine { expertModeOnly: srt.expertmodeonly }
            PQTransparencyMarker { id: trn }
                PQHorizontalLine { expertModeOnly: trn.expertmodeonly }
            PQZoomSpeed { id: zos }

        }

    }

}
