import QtQuick 2.9
import QtQuick.Controls 2.2

import "./interface"

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
                text: "These settings affect the interface in general, how the application looks like and behaves.\nThis includes the background, some of the labels in the main view, which elements are to be shown in their own window, and others. Some settings are only shown in expert mode."
            }

            PQLanguage {}
            PQCloseOnEmpty {}
            PQQuickInfo {}
            PQStartupLoadLast {}
            PQTrayIcon {}
            PQWindowMode {}
            PQBackground {}
            PQHotEdgeWidth {}
            PQWindowManagement {}
            PQMouseWheel {}
            PQOverlayColor {}
            PQPopout {}

        }

    }

}
