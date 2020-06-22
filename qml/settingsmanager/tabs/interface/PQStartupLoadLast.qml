import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "remember last images"
    helptext: "Re-opens last used image at startup."
    content: [
        PQCheckbox {
            id: start_load_last
            text: "re-open last used image at startup"
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            start_load_last.checked = PQSettings.startupLoadLastLoadedImage
        }

        onSaveAllSettings: {
            PQSettings.startupLoadLastLoadedImage = start_load_last.checked
        }

    }

}
