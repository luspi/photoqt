import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Filename-only"
    helptext: "Show only the filename as thumbnail, no actual image."
    expertmodeonly: true
    content: [

        Column {

            spacing: 10

            Row {

                spacing: 10

                PQCheckbox {
                    id: fname_chk
                    y: (parent.height-height)/2
                    text: "Use filename-only thumbnails"
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
                    text: "Font size:"
                }

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
                    text: "5 pt"
                }

                PQSlider {
                    id: fname_fsize
                    y: (parent.height-height)/2
                    enabled: fname_chk.checked
                    from: 5
                    to: 5
                }

                Text {
                    y: (parent.height-height)/2
                    color: fname_chk.checked ? "white" : "#cccccc"
                    text: "20 pt"
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            fname_chk.checked = PQSettings.thumbnailFilenameInstead
            fname_fsize.value = PQSettings.thumbnailFilenameInsteadFontSize
        }

        onSaveAllSettings: {
            PQSettings.thumbnailFilenameInstead = fname_chk.checked
            PQSettings.thumbnailFilenameInsteadFontSize = fname_fsize.value
        }

    }

}
