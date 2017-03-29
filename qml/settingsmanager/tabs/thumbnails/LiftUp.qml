import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            //: Settings title: How many pixels to lift up/down the thumbnails when hovering them with the mouse
            title: qsTr("Lift-Up of Thumbnails")
            helptext: qsTr("When a thumbnail is hovered, it is lifted up some pixels (default 10). Here you can increase/decrease this value according to your personal preference.")

        }

        EntrySetting {

            id: entry

            // This variable is needed to avoid a binding loop of slider<->spinbox
            property int val: 20

            Row {

                spacing: 10

                CustomSlider {

                    id: liftup_slider

                    width: Math.min(400, settings_top.width-entrytitle.width-liftup_spinbox.width-50)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 40

                    tickmarksEnabled: true
                    stepSize: 1

                    onValueChanged:
                        entry.val = value

                }

                CustomSpinBox {

                    id: liftup_spinbox

                    width: 75

                    minimumValue: 0
                    maximumValue: 40

                    suffix: " px"

                    value: entry.val

                    onValueChanged: {
                        if(value%5 == 0)
                            liftup_slider.value = value
                    }

                }

            }

        }

    }

    function setData() {
        liftup_slider.value = settings.thumbnailLiftUp
        entry.val = liftup_slider.value
    }

    function saveData() {
        settings.thumbnailLiftUp = liftup_spinbox.value
    }

}
