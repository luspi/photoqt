import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title. The 'hot edge' refers to the area along the left edge of PhotoQt where the mouse cursor triggers the visibility of the metadata element.
    title: em.pty+qsTranslate("settingsmanager", "hot edge")
    helptext: em.pty+qsTranslate("settingsmanager", "Show metadata element when the mouse cursor is close to the window edge")
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: meta_hot
            text: em.pty+qsTranslate("settingsmanager", "enable")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metadataEnableHotEdge = meta_hot.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        meta_hot.checked = PQSettings.metadataEnableHotEdge
    }

}
