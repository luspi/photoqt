import QtQuick 2.9
import QtQuick.Controls 2.2

import "./metadata"
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
                text: "Metadata settings"
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width
                wrapMode: Text.WordWrap
                text: "These settings affect the metadata element, what information it should show and some of its behavior.\nSome settings are only shown in expert mode."
            }

            PQGPSMap { id: gps }
                PQHorizontalLine { expertModeOnly: gps.expertmodeonly }
            PQHotEdge { id: hot }
                PQHorizontalLine { expertModeOnly: hot.expertmodeonly }
            PQOpacity { id: opa }
                PQHorizontalLine { expertModeOnly: opa.expertmodeonly }
            PQRotation { id: rot }
                PQHorizontalLine { expertModeOnly: rot.expertmodeonly }
            PQMetaData { id: mtd }
                PQHorizontalLine { expertModeOnly: mtd.expertmodeonly }
            PQFaceTags { id: ftg }
                PQHorizontalLine { expertModeOnly: ftg.expertmodeonly }
            PQFaceTagsFontSize { id: ftf }
                PQHorizontalLine { expertModeOnly: ftf.expertmodeonly }
            PQFaceTagsBorder { id: ftb }
                PQHorizontalLine { expertModeOnly: ftb.expertmodeonly }
            PQFaceTagsVisibility { id: ftv }


        }

    }

}
