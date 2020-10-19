import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The face tags are labels that can be shown (if available) on people's faces including their name.
    title: em.pty+qsTranslate("settingsmanager", "face tags")
    //: The face tags are labels that can be shown (if available) on people's faces including their name.
    helptext: em.pty+qsTranslate("settingsmanager", "Whether to show face tags (stored in metadata info).")
    content: [

        PQCheckbox {
            id: ft
            text: em.pty+qsTranslate("settingsmanager", "enable")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.peopleTagInMetaDisplay = ft.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        ft.checked = PQSettings.peopleTagInMetaDisplay
    }

}
