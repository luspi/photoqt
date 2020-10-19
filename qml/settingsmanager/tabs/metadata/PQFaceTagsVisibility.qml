import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title. The face tags are labels that can be shown (if available) on people's faces including their name.
    title: em.pty+qsTranslate("settingsmanager", "face tags - visibility")
    helptext: em.pty+qsTranslate("settingsmanager", "When to show the face tags and for how long.")
    content: [

        PQComboBox {
            id: ft_combo
            //: A mode for showing face tags.
            model: [em.pty+qsTranslate("settingsmanager", "hybrid mode"),
                    //: A mode for showing face tags.
                    em.pty+qsTranslate("settingsmanager", "always show all"),
                    //: A mode for showing face tags.
                    em.pty+qsTranslate("settingsmanager", "show one on hover"),
                    //: A mode for showing face tags.
                    em.pty+qsTranslate("settingsmanager", "show all on hover")]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
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

    Component.onCompleted: {
        load()
    }

    function load() {
        if(PQSettings.peopleTagInMetaHybridMode)
            ft_combo.currentIndex = 0
        else if(PQSettings.peopleTagInMetaAlwaysVisible)
            ft_combo.currentIndex = 1
        else if(PQSettings.peopleTagInMetaIndependentLabels)
            ft_combo.currentIndex = 2
        else
            ft_combo.currentIndex = 3
    }

}
