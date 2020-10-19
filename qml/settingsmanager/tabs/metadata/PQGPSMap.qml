import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager", "GPS online map")
    helptext: em.pty+qsTranslate("settingsmanager", "Which map service to use when a GPS position is clicked.")
    content: [

        PQComboBox {
            id: gps_combo
            model: ["openstreetmap.org", "maps.google.com", "bing.com/maps"]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.metaGpsMapService = gps_combo.currentText
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        for(var i = 0; i < gps_combo.count; ++i)
            if(gps_combo.model[i] == PQSettings.metaGpsMapService)
                gps_combo.currentIndex = i
    }

}
