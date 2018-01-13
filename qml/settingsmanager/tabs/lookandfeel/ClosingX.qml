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

            title: qsTr("Exit button ('x' in top right corner)")
            helptext: qsTr("There are two looks for the exit button: a normal 'x' or a plain text'x'. The normal 'x' fits in better with the overall design of PhotoQt, but the plain text 'x' is smaller and more discreet.")

        }


        EntrySetting {

            Row {

                spacing: 10

                ExclusiveGroup { id: clo; }

                CustomRadioButton {
                    id: closingx_fancy
                    //: This is a type of exit button ('x' in top right screen corner)
                    text: qsTr("Normal")
                    exclusiveGroup: clo
                }
                CustomRadioButton {
                    id: closingx_normal
                    //: This is a type of exit button ('x' in top right screen corner), showing a simple text 'x'
                    text: qsTr("Plain")
                    exclusiveGroup: clo
                    checked: true
                }

                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }

                Row {

                    spacing: 5

                    Text {
                        id: txt_small
                        color: colour.text
                        font.pointSize: 10
                        //: The size of the exit button ('x' in top right screen corner)
                        text: qsTr("Small Size")
                    }

                    CustomSlider {

                        id: closingx_sizeslider

                        width: Math.min(300, settings_top.width-entrytitle.width-closingx_fancy.width-closingx_normal.width
                               -txt_small.width-txt_large.width-80)
                        y: (parent.height-height)/2

                        minimumValue: 5
                        maximumValue: 25

                        tickmarksEnabled: true
                        stepSize: 1

                    }

                    Text {
                        id: txt_large
                        color: colour.text
                        font.pointSize: 10
                        //: The size of the exit button ('x' in top right screen corner)
                        text: qsTr("Large Size")
                    }

                }

            }

        }

    }

    function setData() {
        closingx_fancy.checked = settings.fancyX
        closingx_sizeslider.value = settings.closeXsize
    }

    function saveData() {
        settings.fancyX = closingx_fancy.checked
        settings.closeXsize = closingx_sizeslider.value
    }

}
