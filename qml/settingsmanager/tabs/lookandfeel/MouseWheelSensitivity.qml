import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: qsTr("Mouse Wheel Sensitivity")
            helptext: qsTr("The mouse can be used for various things, including many types of shortcuts. The sensitivity of the mouse wheel defines the distance the wheel has to be moved before triggering a shortcut.")

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {

                    id: txt_no
                    color: colour.text
                    //: Refers to the sensitivity of the mouse wheel
                    text: qsTr("Not at all sensitive")
                    font.pointSize: 10

                }

                CustomSlider {

                    id: wheelsensitivity

                    width: Math.min(400, settings_top.width-entrytitle.width-txt_no.width-txt_very.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 1
                    maximumValue: 10

                    tickmarksEnabled: true
                    stepSize: 1

                }

                Text {

                    id: txt_very
                    color: colour.text
                    //: Refers to the sensitivity of the mouse wheel
                    text: qsTr("Very sensitive")
                    font.pointSize: 10

                }

            }

        }

    }

    function setData() {
        wheelsensitivity.value = wheelsensitivity.maximumValue-settings.mouseWheelSensitivity
    }

    function saveData() {
        settings.mouseWheelSensitivity = wheelsensitivity.maximumValue-wheelsensitivity.value
    }

}
