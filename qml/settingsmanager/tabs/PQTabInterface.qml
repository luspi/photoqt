import QtQuick 2.9
import QtQuick.Controls 2.2

import "./interface"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height

        anchors.fill: parent

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
            y: 0

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
                text: "These settings affect the interface in general, how the application looks like and behaves.\nThis includes the background, some of the labels in the main view, which elements are to be shown in their own window, and others. Some settings are only shown in expert mode."
            }

            PQLanguage { id: lng }
                PQHorizontalLine { expertModeOnly: lng.expertmodeonly }
            PQCloseOnEmpty { id: coe }
                PQHorizontalLine { expertModeOnly: coe.expertmodeonly }
            PQQuickInfo { id: qck }
                PQHorizontalLine { expertModeOnly: qck.expertmodeonly }
            PQStartupLoadLast { id: sll }
                PQHorizontalLine { expertModeOnly: sll.expertmodeonly }
            PQTrayIcon { id: tic }
                PQHorizontalLine { expertModeOnly: tic.expertmodeonly }
            PQWindowMode { id: wmo }
                PQHorizontalLine { expertModeOnly: wmo.expertmodeonly }
            PQBackground { id: bck }
                PQHorizontalLine { expertModeOnly: bck.expertmodeonly }
            PQHotEdgeWidth { id: hew }
                PQHorizontalLine { expertModeOnly: hew.expertmodeonly }
            PQWindowManagement { id: wma }
                PQHorizontalLine { expertModeOnly: wma.expertmodeonly }
            PQMouseWheel { id: mwh }
                PQHorizontalLine { expertModeOnly: mwh.expertmodeonly }
            PQOverlayColor { id: ovc }
                PQHorizontalLine { expertModeOnly: ovc.expertmodeonly }
            PQPopout { id: pop }

        }

    }

}
