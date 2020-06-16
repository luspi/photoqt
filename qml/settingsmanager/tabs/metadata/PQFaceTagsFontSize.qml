import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Face tags - font size"
    helptext: "The font size of the name labels."
    expertmodeonly: true
    content: [

        Row {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "5 pt"
            }

            PQSlider {
                id: ft_fs
                y: (parent.height-height)/2
                from: 5
                to: 50
                toolTipSuffix: " pt"
            }

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "50 pt"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            ft_fs.value = PQSettings.peopleTagInMetaFontSize
        }

        onSaveAllSettings: {
            PQSettings.peopleTagInMetaFontSize = ft_fs.value
        }

    }

}
