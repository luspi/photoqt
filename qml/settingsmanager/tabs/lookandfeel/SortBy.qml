import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Sort Images")
            helptext: qsTr("Here you can adjust, how the images in a folder are supposed to be sorted. You can sort them by Filename, Natural Name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), File Size, and Date. Also, you can reverse the sorting order from ascending to descending if wanted.")

        }

        EntrySetting {

            Row {

                spacing: 10

                // Label
                Text {
                    y: (parent.height-height)/2
                    color: colour.text
                    text: qsTr("Sort by:")
                    font.pointSize: 10
                }
                // Choose Criteria
                CustomComboBox {
                    id: sortimages_checkbox
                    y: (parent.height-height)/2
                    width: 150
                    model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("Filesize")]
                }

                // Ascending or Descending
                ExclusiveGroup { id: radiobuttons_sorting }

                CustomRadioButton {
                    id: sortimages_ascending
                    y: (parent.height-height)/2
                    text: qsTr("Ascending")
                    icon: "qrc:/img/settings/sortascending.png"
                    exclusiveGroup: radiobuttons_sorting
                    checked: true
                }
                CustomRadioButton {
                    id: sortimages_descending
                    y: (parent.height-height)/2
                    text: qsTr("Descending")
                    icon: "qrc:/img/settings/sortdescending.png"
                    exclusiveGroup: radiobuttons_sorting
                }

            }

        }

    }

    function setData() {
        if(settings.sortby === "name")
            sortimages_checkbox.currentIndex = 0
        else if(settings.sortby === "naturalname")
            sortimages_checkbox.currentIndex = 1
        else if(settings.sortby === "date")
            sortimages_checkbox.currentIndex = 2
        else if(settings.sortby === "size")
            sortimages_checkbox.currentIndex = 3
    }

    function saveData() {
        if(sortimages_checkbox.currentIndex == 0)
            settings.sortby = "name"
        else if(sortimages_checkbox.currentIndex == 1)
            settings.sortby = "naturalname"
        else if(sortimages_checkbox.currentIndex == 2)
            settings.sortby = "date"
        else if(sortimages_checkbox.currentIndex == 3)
            settings.sortby = "size"
    }

}
