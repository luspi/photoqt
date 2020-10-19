import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    //: A settings title
    title: em.pty+qsTranslate("settingsmanager", "sort images by")
    helptext: em.pty+qsTranslate("settingsmanager", "Sort all images in a folder by the set property.")
    content: [

        Flow  {

            spacing: 10
            width: set.contwidth

            PQComboBox {
                id: sort_combo
                //: A criteria for sorting images
                model: [em.pty+qsTranslate("settingsmanager", "natural name"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager", "name"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager", "time"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager", "size"),
                        //: A criteria for sorting images
                        em.pty+qsTranslate("settingsmanager", "type")]
            }

            PQRadioButton {
                id: sort_asc
                height: sort_combo.height
                //: Sort images in ascending order
                text: em.pty+qsTranslate("settingsmanager", "ascending")
            }

            PQRadioButton {
                id: sort_desc
                height: sort_combo.height
                //: Sort images in descending order
                text: em.pty+qsTranslate("settingsmanager", "descending")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            if(sort_combo.currentIndex == 0)
                PQSettings.sortby = "naturalname"
            else if(sort_combo.currentIndex == 1)
                PQSettings.sortby = "name"
            else if(sort_combo.currentIndex == 2)
                PQSettings.sortby = "time"
            else if(sort_combo.currentIndex == 3)
                PQSettings.sortby = "size"
            else
                PQSettings.sortby = "type"

            PQSettings.sortbyAscending = sort_asc.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {
        if(PQSettings.sortby == "name")
            sort_combo.currentIndex = 1
        else if(PQSettings.sortby == "time")
            sort_combo.currentIndex = 2
        else if(PQSettings.sortby == "size")
            sort_combo.currentIndex = 3
        else if(PQSettings.sortby == "type")
            sort_combo.currentIndex = 4
        else
            sort_combo.currentIndex = 0

        sort_asc.checked = PQSettings.sortbyAscending
        sort_desc.checked = !PQSettings.sortbyAscending
    }

}
