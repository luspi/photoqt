import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager_imageview", "transparency marker")
    helptext: em.pty+qsTranslate("settingsmanager_imageview", "Show checkerboard pattern behind transparent areas of (half-)transparent images.")
    content: [

        PQCheckbox {
            id: trans_chk
            //: Setting for how to display images that have transparent areas, whether to show checkerboard pattern in that area or not
            text: em.pty+qsTranslate("settingsmanager_imageview", "show checkerboard pattern")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.showTransparencyMarkerBackground = trans_chk.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        trans_chk.checked = PQSettings.showTransparencyMarkerBackground
    }

}
