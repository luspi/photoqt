import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Font Size")
            helptext: qsTr("Computers can have very different resolutions. On some of them, it might be nice to increase the font size of the labels to have them easier readable. Often, a size of 8 or 9 should be working quite well...")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: fontsize_slider

                    width: 400
                    y: (parent.height-height)/2

                    minimumValue: 5
                    maximumValue: 20

                    tickmarksEnabled: true
                    stepSize: 1

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: fontsize_spinbox

                    width: 75

                    minimumValue: 5
                    maximumValue: 20

                    suffix: " pt"

                    value: entry.val

                    onValueChanged:
                        fontsize_slider.value = value

                }

            }

        }

    }

    function setData() {
        fontsize_slider.value = settings.exiffontsize
    }

    function saveData() {
        settings.exiffontsize = fontsize_slider.value
    }

}
