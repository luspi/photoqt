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
            helptext: qsTr("Some cameras can detect - while taking the photo - whether the camera was turned and might store this information in the image exif data. If PhotoQt finds this information, it can rotate the image accordingly. When asking PhotoQt to always rotate images automatically without asking, it already does so at image load (including thumbnails).")

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
                CustomRadioButton {
                    id: alwaysask
                    text: qsTr("Always ask")
                    exclusiveGroup: rotateflipgroup
                }

            }

        }

    }

    function setData() {
        neverrotate.checked = (settings.metaRotation === "Never")
        alwaysrotate.checked = (settings.metaRotation === "Always")
        alwaysask.checked = (settings.metaRotation === "Ask")
    }

    function saveData() {
        settings.metaRotation = neverrotate.checked ? "Never" : (alwaysrotate.checked ? "Always" : "Ask")
    }

}
