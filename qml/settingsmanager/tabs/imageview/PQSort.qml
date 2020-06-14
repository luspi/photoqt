import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    title: "Sort Images"
    helptext: "Sort all images in a folder by the set property."
    content: [

        Row  {

            spacing: 10

            Text {
                y: (parent.height-height)/2
                color: "white"
                text: "Sort by:"
            }

            PQComboBox {
                id: sort_combo
                y: (parent.height-height)/2
                model: ["Natural Name", "Name", "Time", "Size", "Type"]
            }

            PQRadioButton {
                id: sort_asc
                y: (parent.height-height)/2
                text: "Ascending"
            }

            PQRadioButton {
                id: sort_desc
                y: (parent.height-height)/2
                text: "Descending"
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
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

}
