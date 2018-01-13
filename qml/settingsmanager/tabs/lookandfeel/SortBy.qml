import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Sort Images")

            helptext: qsTr("Images in the current folder can be sorted in varios ways. The can be sorted by filename, natural name (e.g., file10.jpg comes after file9.jpg and not after file1.jpg), filesize, and date, all of that both ascending or descending.")

        }

        EntrySetting {

            Row {

                spacing: 10

                // Label
                Text {
                    y: (parent.height-height)/2
                    color: colour.text
                    //: As in "Sort the images by some criteria"
                    text: qsTr("Sort by:")
                    font.pointSize: 10
                }
                // Choose Criteria
                CustomComboBox {
                    id: sortimages_checkbox
                    y: (parent.height-height)/2
                    width: 150
                    //: Refers to the filename
                    model: [qsTr("Name"),
                            //: Sorting by natural name means file10.jpg comes after file9.jpg and not after file1.jpg
                            qsTr("Natural Name"),
                            //: The date the file was created
                            qsTr("Date"),
                            qsTr("Filesize")]
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
