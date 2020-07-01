import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "filename label"
    helptext: "Show the filename on a small label on the thumbnail image."
    content: [

        Column {

            spacing: 15

            Row {

                spacing: 10

                PQCheckbox {
                    id: fnamelabel_chk
                    y: (parent.height-height)/2
                    text: "enable"
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: "font size:"
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
            load()
        }

        onSaveAllSettings: {
            PQSettings.thumbnailWriteFilename = fnamelabel_chk.checked
            PQSettings.thumbnailFontSize = fnamelabel_fsize.value
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        fnamelabel_chk.checked = PQSettings.thumbnailWriteFilename
        fnamelabel_fsize.value = PQSettings.thumbnailFontSize
    }

}
