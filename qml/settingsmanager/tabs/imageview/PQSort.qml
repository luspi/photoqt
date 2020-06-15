import QtQuick 2.9
import QtQuick.Controls 2.2

import "../../../elements"

PQSetting {
    id: set
    title: "Sort Images"
    helptext: "Sort all images in a folder by the set property."
    content: [

        Flow  {

            spacing: 10
            width: set.contwidth

            Text {
                height: sort_combo.height
                verticalAlignment: Text.AlignVCenter
                color: "white"
                text: "Sort by:"
            }

            PQComboBox {
                id: sort_combo
                model: ["Natural Name", "Name", "Time", "Size", "Type"]
            }

            PQRadioButton {
                id: sort_asc
                height: sort_combo.height
                text: "Ascending"
            }

            PQRadioButton {
                id: sort_desc
                height: sort_combo.height
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
