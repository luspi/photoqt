import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: The empty area is the area around the main image
            title: qsTr("Click on Empty Area")
            helptext: qsTr("This option makes PhotoQt behave a bit like the JavaScript image viewers you find on many websites. A click outside of the image on the empty background will close the application. This way PhotoQt will feel even more like a 'floating layer', however, this can easily be triggered accidentally. Note that if you use a mouse click for a shortcut already, then this option wont have any effect!")

        }

        EntrySetting {

            CustomCheckBox {

                id: closeongrey
                //: The empty area is the area around the main image
                text: qsTr("Close on click in empty area")

            }

        }

    }

    function setData() {
        closeongrey.checkedButton = settings.closeongrey
    }

    function saveData() {
        settings.closeongrey = closeongrey.checkedButton
    }

}
