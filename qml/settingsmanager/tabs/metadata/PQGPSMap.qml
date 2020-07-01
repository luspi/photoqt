import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "GPS online map"
    helptext: "Which map service to use to show location of GPS positions."
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
