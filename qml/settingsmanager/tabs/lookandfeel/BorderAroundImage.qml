import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            title: em.pty+qsTr("Margin Around Image")
            helptext: em.pty+qsTr("Whenever you load an image, the image is per default not shown completely in fullscreen, i.e. it's not stretching from screen edge to screen edge. Instead there is a small margin around the image of a couple pixels. Here you can adjust the width of this margin (set to 0 to disable it).")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomSlider {

                    id: border_sizeslider

                    width: Math.min(400, settings_top.width-entrytitle.width-border_sizespinbox.width-60)
                    y: (parent.height-height)/2

                    minimumValue: 0
                    maximumValue: 100

                    value: border_sizespinbox.value
                    tickmarksEnabled: true
                    stepSize: 1

                }

                CustomSpinBox {

                    id: border_sizespinbox

                    width: 75

                    minimumValue: 0
                    maximumValue: 100

                    value: border_sizeslider.value
                    suffix: " px"

                }

            }

        }

    }

    function setData() {
        border_sizeslider.value = settings.marginAroundImage
    }

    function saveData() {
        settings.marginAroundImage = border_sizeslider.value
    }

}
