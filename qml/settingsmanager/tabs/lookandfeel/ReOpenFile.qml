import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Re-open last used image at startup")
            helptext: em.pty+qsTr("At startup, you can set PhotoQt to re-open the last used image and directory. This doesn't keep any zooming/scaling/mirroring from before. If you pass an image to PhotoQt on the command line, it will always favor the passed-on image.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: reopen_box
                    text: em.pty+qsTr("Re-open last used image")
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
