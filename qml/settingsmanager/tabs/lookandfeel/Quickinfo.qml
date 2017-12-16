import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Show Quickinfo (Text Labels)")
            helptext: qsTr("Here you can hide the text labels shown in the main area: The Counter in the top left corner, the file path/name following the counter, and the \"X\" displayed in the top right corner. The labels can also be hidden by simply right-clicking on them and selecting \"Hide\".")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: quickinfo_counter
                    text: qsTr("Counter")
                }

                CustomCheckBox {
                    id: quickinfo_filename
                    text: qsTr("Filename")
                }

                CustomCheckBox {
                    id: quickinfo_filepath
                    text: qsTr("Filepath and Filename")
                }

                CustomCheckBox {
                    id: quickinfo_closingx
                    text: qsTr("Exit button ('x' in top right corner)")
                }

            }

        }

    }

    function saveData() {
        settings.hidecounter = !quickinfo_counter.checkedButton
        settings.hidefilepathshowfilename = !quickinfo_filepath.checkedButton
        settings.hidefilename = !quickinfo_filename.checkedButton
        settings.hidex = !quickinfo_closingx.checkedButton
    }

    function setData() {
        quickinfo_counter.checkedButton = !settings.hidecounter
        quickinfo_filepath.checkedButton = !settings.hidefilepathshowfilename
        quickinfo_filename.checkedButton = !settings.hidefilename
        quickinfo_closingx.checkedButton = !settings.hidex
    }

}
