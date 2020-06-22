import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "visibility"
    helptext: "If and how to keep thumbnails visible"
    content: [

        PQComboBox {
            id: thb_vis
            model: ["hide when not needed",
                    "never hide",
                    "hide when zoomed in"]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            if(PQSettings.thumbnailKeepVisible)
                thb_vis.currentIndex = 1
            else if(PQSettings.thumbnailKeepVisibleWhenNotZoomedIn)
                thb_vis.currentIndex = 2
            else
                thb_vis.currentIndex = 0
        }

        onSaveAllSettings: {
            if(thb_vis.currentIndex == 0) {
                PQSettings.thumbnailKeepVisible = false
                PQSettings.thumbnailKeepVisibleWhenNotZoomedIn = false
            } else if(thb_vis.currentIndex == 1) {
                PQSettings.thumbnailKeepVisible = true
                PQSettings.thumbnailKeepVisibleWhenNotZoomedIn = false
            } else {
                PQSettings.thumbnailKeepVisible = false
                PQSettings.thumbnailKeepVisibleWhenNotZoomedIn = true
            }
        }

    }

}
