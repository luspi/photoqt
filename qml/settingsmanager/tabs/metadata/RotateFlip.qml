import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Automatic Rotate/Flip")
            helptext: qsTr("Some cameras can detect - while taking the photo - whether the camera was turned and might store this information in the image exif data. If PhotoQt finds this information, it can rotate the image accordingly or simply ignore that information.")

        }

        EntrySetting {

            id: entry

            ExclusiveGroup { id: rotateflipgroup; }

            Row {

                spacing: 10

                CustomRadioButton {
                    id: neverrotate
                    text: qsTr("Never rotate/flip images")
                    exclusiveGroup: rotateflipgroup
                    checked: true
                }
                CustomRadioButton {
                    id: alwaysrotate
                    text: qsTr("Always rotate/flip images")
                    exclusiveGroup: rotateflipgroup
                }

            }

        }

    }

    function setData() {
        neverrotate.checked = !settings.metaApplyRotation
        alwaysrotate.checked = settings.metaApplyRotation
    }

    function saveData() {
        settings.metaApplyRotation = alwaysrotate.checked
    }

}
