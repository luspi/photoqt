import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Blur Intensity")
            helptext: qsTr("The background elements are blurred out, when a widget like the Settings Manager or the About widget is opened. Here you can adjust the intensity of the blur.") + "<br><br><b> " + qsTr("Please note") + "</b>: " + qsTr("This does NOT affect the blur of the desktop BEHIND PhotoQt (when transparency is enabled).")

        }

        EntrySetting {

            Row {

                spacing: 5

                Text {
                    color: colour.text
                    font.pointSize: 10
                    text: qsTr("No Blur")
                }

                CustomSlider {

                    id: blur_intensity

                    width: 300
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 10

                    tickmarksEnabled: true
                    stepSize: 1

                }

                Text {
                    color: colour.text
                    font.pointSize: 10
                    text: qsTr("Crazy Blur")
                }

            }

        }

    }

    function setData() {
        blur_intensity.value = settings.blurIntensity
    }

    function saveData() {
        settings.blurIntensity = blur_intensity.value
    }

}
