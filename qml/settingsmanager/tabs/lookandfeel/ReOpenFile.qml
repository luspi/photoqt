import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Re-open last used image at startup")
            helptext: qsTr("At startup, you can set PhotoQt to re-open the last used image and directory. This doesn't keep any zooming/scaling/mirroring from before. If you pass an image to PhotoQt on the command line, PhotoQt will always favour the passed-on image and skip this setting here.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: reopen_box
                    text: qsTr("Re-open last used image")
                }

            }

        }

    }

    function setData() {
        reopen_box.checkedButton = settings.startupLoadLastLoadedImage
    }

    function saveData() {
        settings.startupLoadLastLoadedImage = reopen_box.checkedButton
    }

}
