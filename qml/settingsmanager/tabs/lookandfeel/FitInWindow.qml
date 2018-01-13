import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: Along the lines of 'zoom small images until they fill the window'
            title: qsTr("Fit in Window")
            helptext: qsTr("If the image dimensions are smaller than the screen dimensions, PhotoQt can automatically zoom those images to make them fit into the window.")

        }

        EntrySetting {

            CustomCheckBox {

                id: fitinwindow
                text: qsTr("Fit Smaller Images in Window")

            }

        }

    }

    function setData() {
        fitinwindow.checkedButton = settings.fitInWindow
    }

    function saveData() {
        settings.fitInWindow = fitinwindow.checkedButton
    }

}
