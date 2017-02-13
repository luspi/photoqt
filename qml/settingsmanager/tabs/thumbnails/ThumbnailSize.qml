import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            //: Settings title: What pixel size to use for the thumbnails
            title: qsTr("Thumbnail Size")
            helptext: qsTr("Here you can adjust the thumbnail size. You can set it to any size between 20 and 256 pixel. Per default it is set to 80 pixel, but with different screen resolutions it might be nice to have them larger/smaller.")

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
        size_slider.value = settings.thumbnailsize
        entry.val = size_slider.value
    }

    function saveData() {
        settings.thumbnailsize = size_spinbox.value
    }

}
