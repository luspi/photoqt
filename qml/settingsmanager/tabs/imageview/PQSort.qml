import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "sort images by"
    helptext: "Sort all images in a folder by the set property."
    content: [

        Flow  {

            spacing: 10
            width: set.contwidth

            PQComboBox {
                id: sort_combo
                model: ["natural name", "name", "time", "size", "type"]
            }

            PQRadioButton {
                id: sort_asc
                height: sort_combo.height
                text: "ascending"
            }

            PQRadioButton {
                id: sort_desc
                height: sort_combo.height
                text: "descending"
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
