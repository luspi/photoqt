import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Filename label"
    helptext: "Show the filename on a small label on the thumbnail image."
    content: [

        Column {

            spacing: 10

            Row {

                spacing: 10

                PQCheckbox {
                    id: fnamelabel_chk
                    y: (parent.height-height)/2
                    text: "Write small label onto thumbnails"
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "Font size:"
                }

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "5 pt"
                }

                PQSlider {
                    id: fnamelabel_fsize
                    y: (parent.height-height)/2
                    enabled: fnamelabel_chk.checked
                    from: 5
                    to: 5
                }

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "20 pt"
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            fnamelabel_chk.checked = PQSettings.thumbnailWriteFilename
            fnamelabel_fsize.value = PQSettings.thumbnailFontSize
        }

        onSaveAllSettings: {
            PQSettings.thumbnailWriteFilename = fnamelabel_chk.checked
            PQSettings.thumbnailFontSize = fnamelabel_fsize.value
        }

    }

}
