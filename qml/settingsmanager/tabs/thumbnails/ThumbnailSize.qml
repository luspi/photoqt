import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: em.pty+qsTr("Thumbnail Size")
            helptext: em.pty+qsTr("Here you can adjust the thumbnail size. You can set it to any size between 20 and 256 pixel. Per default it is set to 80 pixel, but the optimal size depends on the screen resolution.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: size_slider

                    width: Math.min(400, settings_top.width-entrytitle.width-size_spinbox.width-50)
                    y: (parent.height-height)/2

                    minimumValue: 20
                    maximumValue: 256

                    tickmarksEnabled: true
                    stepSize: 5
                    scrollStep: 5

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: size_spinbox

                    width: 75

                    minimumValue: 20
                    maximumValue: 256

                    suffix: " px"

                    value: entry.val

                    onValueChanged: {
                        if(value%5 == 0)
                            size_slider.value = value
                    }

                }


            }

        }

    }

    function setData() {
        size_slider.value = settings.thumbnailSize
        entry.val = size_slider.value
    }

    function saveData() {
        settings.thumbnailSize = size_spinbox.value
    }

}
