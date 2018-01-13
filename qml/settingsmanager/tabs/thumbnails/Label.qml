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

            title: qsTr("Label on Thumbnails")
            helptext: qsTr("PhotoQt can write a label with some information on the thumbnails. Currently, only the filename is available. The slider adjusts the fontsize of the text for the filename.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 10

                CustomCheckBox {
                    id: writefilename
                    y: (parent.height-height)/2
                    //: Settings: Write the filename on a thumbnail
                    text: qsTr("Write Filename")
                }

                Rectangle { color: "transparent"; width: 10; height: 1; }

                Text {
                    id: txt_fontsize
                    color: enabled ? colour.text : colour.text_inactive
                    Behavior on color { ColorAnimation { duration: 150; } }
                    y: (parent.height-height)/2
                    enabled: writefilename.checkedButton
                    opacity: enabled ? 1 : 0.5
                    //: Settings: Write the filename with this fontsize on a thumbnail
                    text: qsTr("Fontsize") + ":"
                }

                CustomSlider {

                    id: fontsize_slider

                    width: Math.min(400, Math.max(50,settings_top.width-entrytitle.width-writefilename.width-txt_fontsize.width-fontsize_spinbox.width-80))
                    y: (parent.height-height)/2

                    minimumValue: 5
                    maximumValue: 20

                    value: fontsize_spinbox.value
                    stepSize: 1
                    scrollStep: 1
                    tickmarksEnabled: true

                    enabled: writefilename.checkedButton

                }

                CustomSpinBox {

                    id: fontsize_spinbox
                    y: (parent.height-height)/2

                    width: 75

                    minimumValue: 5
                    maximumValue: 20

                    value: fontsize_slider.value

                    enabled: writefilename.checkedButton

                }

            }

        }

    }

    function setData() {
        writefilename.checkedButton = settings.thumbnailWriteFilename
        fontsize_slider.value = settings.thumbnailFontSize
    }

    function saveData() {
        settings.thumbnailWriteFilename = writefilename.checkedButton
        settings.thumbnailFontSize = fontsize_slider.value
    }

}
