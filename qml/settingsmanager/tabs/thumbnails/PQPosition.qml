import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Position"
    helptext: "Which edge to show the thumbnails on, upper or lower edge."
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "Show Thumbnails on which edge:"
            }

            PQComboBox {
                id: edge
                y: (parent.height-height)/2
                model: ["upper edge", "lower edge"]
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            if(PQSettings.thumbnailPosition == "Top")
                edge.currentIndex = 0
            else
                edge.currentIndex = 1
        }

        onSaveAllSettings: {
            if(edge.currentIndex == 0)
                PQSettings.thumbnailPosition == "Bottom"
            else
                PQSettings.thumbnailPosition == "Top"
        }

    }

}
