import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_metadata", "auto-rotation")
    helptext: em.pty+qsTranslate("settingsmanager_metadata", "Automatically rotate images based on metadata information.")
    expertmodeonly: true
    content: [

        PQCheckbox {
            id: meta_rot
            text: em.pty+qsTranslate("settingsmanager_metadata", "enable")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metaApplyRotation = meta_rot.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        meta_rot.checked = PQSettings.metaApplyRotation
    }

}
