import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Keep between images")
            helptext: qsTr("If you would like PhotoQt to keep the set rotation, flipping and zoom level when switching images, then you can enable that here. If not set, then every time a new image is displayed, it is displayed neither zoomed nor rotated nor flipped.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: keep_box
                    text: qsTr("Keep Zoom, Rotation, Flip")
                }

            }

        }

    }

    function setData() {
        keep_box.checkedButton = settings.keepZoomRotationMirror
    }

    function saveData() {
        settings.keepZoomRotationMirror = keep_box.checkedButton
    }

}
