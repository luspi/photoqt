import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. The filename label here is the one that is written on thumbnails.
    title: em.pty+qsTranslate("settingsmanager", "filename label")
    helptext: em.pty+qsTranslate("settingsmanager", "Show the filename on a small label on the thumbnail image.")
    content: [

        Column {

            spacing: 15

            Row {

                spacing: 10

                PQCheckbox {
                    id: fnamelabel_chk
                    y: (parent.height-height)/2
                    text: em.pty+qsTranslate("settingsmanager", "enable")
                }

            }

            Row {

                spacing: 10

                Text {
                    y: (parent.height-height)/2
                    color: fnamelabel_chk.checked ? "white" : "#cccccc"
                    text: em.pty+qsTranslate("settingsmanager", "font size:")
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
                    to: 20
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
