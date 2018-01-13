import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //:Refers to keeping zoom/rotation/flip/position when switching images
            title: qsTr("Keep between images")
            helptext: qsTr("By default, PhotoQt resets the zoom, rotation, flipping/mirroring and position when switching to a different image. For certain tasks, for example for comparing two images, it can be helpful to keep these properties.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: keep_box
                    //: Remember all these levels when switching between images
                    text: qsTr("Keep Zoom, Rotation, Flip, Position")
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
