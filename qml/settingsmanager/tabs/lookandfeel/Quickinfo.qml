import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Show Quickinfo (Text Labels)")
            helptext: em.pty+qsTr("PhotoQt shows certain information about the current image and the folder in the top left corner of the screen. You can choose which information in particular to show there. This also includes the 'x' for closing PhotoQt in the top right corner.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: quickinfo_counter
                    //: The counter shows the current image position in the folder
                    text: em.pty+qsTr("Counter")
                }

                CustomCheckBox {
                    id: quickinfo_filepath
                    text: em.pty+qsTr("Filepath")
                }

                CustomCheckBox {
                    id: quickinfo_filename
                    text: em.pty+qsTr("Filename")
                }

                CustomCheckBox {
                    id: quickinfo_closingx
                    text: em.pty+qsTr("Exit button ('x' in top right corner)")
                }

            }

        }

    }

    function saveData() {
        settings.quickInfoHideCounter = !quickinfo_counter.checkedButton
        settings.quickInfoHideFilepath = !quickinfo_filepath.checkedButton
        settings.quickInfoHideFilename = !quickinfo_filename.checkedButton
        settings.quickInfoHideX = !quickinfo_closingx.checkedButton
    }

    function setData() {
        quickinfo_counter.checkedButton = !settings.quickInfoHideCounter
        quickinfo_filepath.checkedButton = !settings.quickInfoHideFilepath
        quickinfo_filename.checkedButton = !settings.quickInfoHideFilename
        quickinfo_closingx.checkedButton = !settings.quickInfoHideX
    }

}
