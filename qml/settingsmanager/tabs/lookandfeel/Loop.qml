import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: Refers to looping through the folder, i.e., from the last image go back to the first one (and vice versa)
            title: qsTr("Looping")
            helptext: qsTr("PhotoQt can loop over the images in the folder, i.e., when reaching the last image it continues to the first one and vice versa. If disabled, it will stop at the first/last image.")

        }

        EntrySetting {

            CustomCheckBox {

                id: loopfolder
                text: qsTr("Loop through images in folder")

            }

        }

    }

    function setData() {
        loopfolder.checkedButton = settings.loopthroughfolder
    }

    function saveData() {
        settings.loopthroughfolder = loopfolder.checkedButton
    }

}
