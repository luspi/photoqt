import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Opacity")
            helptext: qsTr("By default, the metadata widget is overlapping the main image, thus you might prefer a different alpha value for opacity to increase/decrease readability. Values can be in the range of 0-255.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: opacity_slider

                    width: 400
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 255

                    stepSize: 5
                    scrollStep: 5

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: opacity_spinbox

                    width: 75

                    minimumValue: 0
                    maximumValue: 255

                    value: entry.val

                    onValueChanged:
                        opacity_slider.value = value

                }

            }

        }

    }

    function setData() {
        opacity_slider.value = settings.exifopacity
    }

    function saveData() {
        settings.exifopacity = opacity_slider.value
    }

}
