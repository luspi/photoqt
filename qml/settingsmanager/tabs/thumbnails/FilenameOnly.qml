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

            title: qsTr("Filename Thumbnail")
            helptext: qsTr("If you don't want PhotoQt to always load the actual image thumbnail in the background, but you still want to have something for better navigating, then you can set a filename-only thumbnail, i.e. PhotoQt wont load any thumbnail images but simply puts the file name into the box. You can also adjust the font size of this text.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 10

                CustomCheckBox {
                    id: filenameonly
                    text: qsTr("Use filename-only thumbnail")
                }

                Rectangle { color: "transparent"; width: 10; height: 1; }

                Text {
                    id: txt_fontsize
                    color: enabled ? colour.text : colour.text_inactive
                    Behavior on color { ColorAnimation { duration: 150; } }
                    y: (parent.height-height)/2
                    enabled: filenameonly.checkedButton
                    opacity: enabled ? 1 : 0.5
                    text: qsTr("Fontsize") + ":"
                }

                CustomSlider {

                    id: filenameonly_fontsize_slider

                    width: Math.min(400, Math.max(50,settings_top.width-entrytitle.width-filenameonly.width-txt_fontsize.width-filenameonly_fontsize_spinbox.width-80))
                    y: (parent.height-height)/2

                    minimumValue: 5
                    maximumValue: 20

                    enabled: filenameonly.checkedButton

                    value: filenameonly_fontsize_spinbox.value
                    stepSize: 1
                    scrollStep: 1
                    tickmarksEnabled: true

                }

                CustomSpinBox {

                    id: filenameonly_fontsize_spinbox

                    width: 75

                    minimumValue: 5
                    maximumValue: 20

                    enabled: filenameonly.checkedButton

                    value: filenameonly_fontsize_slider.value

                }

            }

        }

    }

    function setData() {
        filenameonly.checkedButton = settings.thumbnailFilenameInstead
        filenameonly_fontsize_slider.value = settings.thumbnailFilenameInsteadFontSize
    }

    function saveData() {
        settings.thumbnailFilenameInstead = filenameonly.checkedButton
        settings.thumbnailFilenameInsteadFontSize = filenameonly_fontsize_slider.value
    }

}
