import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The face tags are labels that can be shown (if available) on people's faces including their name.
    title: em.pty+qsTranslate("settingsmanager", "face tags - font size")
    //: The name labels here are the labels with the name used for the face tags.
    helptext: em.pty+qsTranslate("settingsmanager", "The font size of the name labels.")
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
            load()
        }

        onSaveAllSettings: {
            PQSettings.peopleTagInMetaFontSize = ft_fs.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        ft_fs.value = PQSettings.peopleTagInMetaFontSize
    }

}
