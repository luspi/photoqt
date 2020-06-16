import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Face tags - visibility"
    helptext: "When to show the face tags and for how long."
    content: [

        PQComboBox {
            id: ft_combo
            model: ["Hybrid mode", "Always show all", "Show one on hover", "Show all on hover"]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            if(PQSettings.peopleTagInMetaHybridMode)
                ft_combo.currentIndex = 0
            else if(PQSettings.peopleTagInMetaAlwaysVisible)
                ft_combo.currentIndex = 1
            else if(PQSettings.peopleTagInMetaIndependentLabels)
                ft_combo.currentIndex = 2
            else
                ft_combo.currentIndex = 3
        }

        onSaveAllSettings: {
            if(ft_combo.currentIndex == 0) {
                PQSettings.peopleTagInMetaHybridMode = true
                PQSettings.peopleTagInMetaAlwaysVisible = false
                PQSettings.peopleTagInMetaIndependentLabels = false
            } else if(ft_combo.currentIndex == 1) {
                PQSettings.peopleTagInMetaHybridMode = false
                PQSettings.peopleTagInMetaAlwaysVisible = true
                PQSettings.peopleTagInMetaIndependentLabels = false
            } else if(ft_combo.currentIndex == 2) {
                PQSettings.peopleTagInMetaHybridMode = false
                PQSettings.peopleTagInMetaAlwaysVisible = false
                PQSettings.peopleTagInMetaIndependentLabels = true
            } else {
                PQSettings.peopleTagInMetaHybridMode = false
                PQSettings.peopleTagInMetaAlwaysVisible = false
                PQSettings.peopleTagInMetaIndependentLabels = false
            }
        }

    }

}
