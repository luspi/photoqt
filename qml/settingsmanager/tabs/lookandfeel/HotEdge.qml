import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            //: The hot edge refers to the left and right screen edge. When the mouse cursor enters the hot edge area, then the main menu/metadata element is shown
            title: qsTr("Size of 'Hot Edge' of main menu")
            helptext: qsTr("Here you can adjust the sensitivity of the metadata and main menu elements. The main menu opens when your mouse cursor gets close to the right screen edge, the metadata element when you go to the left screen edge. This setting controls how close to the screen edge you have to get before they are shown.")

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {
                    id: txt_small
                    color: colour.text
                    //: This refers to the size of the hot edge, you have to get very close to the screen edge to trigger the main menu or metadata element
                    text: qsTr("Small")
                    font.pointSize: 10
                }

                CustomSlider {

                    id: menusensitivity

                    width: Math.min(400, settings_top.width-entrytitle.width-txt_small.width-txt_large.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 1
                    maximumValue: 10

                    tickmarksEnabled: true
                    stepSize: 1

                }

                Text {
                    id: txt_large
                    color: colour.text
                    //: This refers to the size of the hot edge, you don't have to get very close to the screen edge to trigger the main menu or metadata element
                    text: qsTr("Large")
                    font.pointSize: 10
                }

            }

        }

    }

    function setData() {
        menusensitivity.value = settings.menusensitivity
    }

    function saveData() {
        settings.menusensitivity = menusensitivity.value
    }

}
