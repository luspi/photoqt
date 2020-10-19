import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    //: A settings title referring to the position of the thumbnails (upper or lower edge of PhotoQt).
    title: em.pty+qsTranslate("settingsmanager", "position")
    helptext: em.pty+qsTranslate("settingsmanager", "Which edge to show the thumbnails on, upper or lower edge.")
    content: [

        PQComboBox {
            id: edge
            y: (parent.height-height)/2
            //: The upper edge of PhotoQt
            model: [em.pty+qsTranslate("settingsmanager", "upper edge"),
                    //: The lower edge of PhotoQt
                    em.pty+qsTranslate("settingsmanager", "lower edge")]
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            if(edge.currentIndex == 0)
                PQSettings.thumbnailPosition = "Top"
            else
                PQSettings.thumbnailPosition = "Bottom"
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        if(PQSettings.thumbnailPosition == "Top")
            edge.currentIndex = 0
        else
            edge.currentIndex = 1
    }

}
