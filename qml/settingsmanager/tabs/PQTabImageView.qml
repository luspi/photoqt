import QtQuick 2.9
import QtQuick.Controls 2.2

import "./imageview"

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
                text: "Interface settings"
            }

            Text {
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings affect the viewing of images, how they are shown, in what order, how large a cache to use, etc.\nSome settings are only shown in expert mode."
            }

            PQAnimation { }
            PQFitInWindow { }
            PQInterpolation { }
            PQKeep { }
            PQLeftButton { }
            PQLoop { }
            PQMargin { }
            PQPixmapCache { }
            PQSort { }
            PQTransparencyMarker { }
            PQZoomSpeed { }

        }

    }

}
