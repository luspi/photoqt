import QtQuick 2.9
import QtQuick.Controls 2.2

import "./metadata"
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
                text: em.pty+qsTranslate("settingsmanager", "Metadata settings")
            }

            Text {
                id: desc
                color: "white"
                font.pointSize: 12
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings affect the metadata element, what information it should show and some of its behavior.") + "\n" + em.pty+qsTranslate("settingsmanager", "Some settings are only shown in expert mode.")
            }

            PQMetaData { id: mtd }
                PQHorizontalLine { expertModeOnly: mtd.expertmodeonly }
            PQHotEdge { id: hot }
                PQHorizontalLine { expertModeOnly: hot.expertmodeonly }
            PQGPSMap { id: gps }
                PQHorizontalLine { expertModeOnly: gps.expertmodeonly }
            PQOpacity { id: opa }
                PQHorizontalLine { expertModeOnly: opa.expertmodeonly }
            PQRotation { id: rot }
                PQHorizontalLine { expertModeOnly: rot.expertmodeonly }
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
