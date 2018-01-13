import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: entrytitle

            //: The type of interpolation to use for small images
            title: qsTr("Interpolation")
            helptext: qsTr("There are many different interpolation algorithms out there. Depending on the choice of interpolation algorithm, the image (when zoomed in) will look slightly differently. PhotoQt uses mipmaps to get the best quality for images. However, for very small images, that might lead to too much blurring causing them to look rather ugly. For those images, the 'Nearest Neighbour' algorithm tends to be a better choice. The threshold defines for which images to use which algorithm.");

        }

        EntrySetting {

            Row {

                spacing: 10

                Text {

                    id: txt_label
                    color: colour.text
                    //: When to trigger an action, below which threshold
                    text: qsTr("Threshold:")
                    font.pointSize: 10
                    y: (parent.height-height)/2

                }

                CustomSpinBox {

                    id: interpolationthreshold

                    width: 100

                    minimumValue: 0
                    maximumValue: 99999

                    stepSize: 5

                    value: 100
                    suffix: " px"

                }

                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }
                Rectangle { color: "transparent"; width: 1; height: 1; }

                CustomCheckBox {

                    id: interpolationupscale
                    y: (parent.height-height)/2
                    wrapMode: Text.WordWrap
                    fixedwidth: settings_top.width-entrytitle.width-txt_label.width-interpolationthreshold.width-90
                    //: 'Nearest Neighbour' is the name of a specific algorithm
                    text: qsTr("Use 'Nearest Neighbour' algorithm for upscaling")

                }

            }

        }

    }

    function setData() {
        interpolationthreshold.value = settings.interpolationNearestNeighbourThreshold
        interpolationupscale.checkedButton = settings.interpolationNearestNeighbourUpscale
    }

    function saveData() {
        settings.interpolationNearestNeighbourThreshold = interpolationthreshold.value
        settings.interpolationNearestNeighbourUpscale = interpolationupscale.checkedButton
    }

}
