import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            //: The transition refers to images fading into one another when switching between them
            title: em.pty+qsTr("Smooth Transition")
            helptext: em.pty+qsTr("Switching between images can be done smoothly, the new image can be set to fade into the old image. 'No transition' means, that the previous image is simply replaced instantly by the new image.")

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {
                    id: txt_no
                    color: colour.text
                    //: No transition means that images are simply replaced when switching between them, no cross-fading
                    text: em.pty+qsTr("No Transition")
                    font.pointSize: 10
                }

                CustomSlider {

                    id: transition

                    width: Math.min(400, settings_top.width-entrytitle.width-txt_no.width-txt_long.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 10

                    tickmarksEnabled: true
                    stepSize: 1

                }

                Text {
                    id: txt_long
                    color: colour.text
                    //: A very long transition between images, they slowly fade into each other
                    text: em.pty+qsTr("Long Transition")
                    font.pointSize: 10
                }

            }

        }

    }

    function setData() {
        transition.value = settings.imageTransition
    }

    function saveData() {
        settings.imageTransition = transition.value
    }

}
