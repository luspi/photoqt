import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Font Size")
            helptext: qsTr("The fontsize of the metadata element can be adjusted independently of the rest of the application.")

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
        fontsize_slider.value = settings.metadataFontSize
    }

    function saveData() {
        settings.metadataFontSize = fontsize_slider.value
    }

}
