import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Looping")
            helptext: qsTr("When you load the last image in a directory and select 'Next', PhotoQt automatically jumps to the first image (and vice versa: if you select 'Previous' while having the first image loaded, PhotoQt jumps to the last image). Disabling this option makes PhotoQt stop at the first/last image (i.e. selecting 'Next'/'Previous' will have no effect in these two special cases).")

        }

        EntrySetting {

            CustomCheckBox {

                id: loopfolder
                text: qsTr("Loop through images in folder")

            }

        }

    }

    function setData() {
        loopfolder.checkedButton = settings.loopthroughfolder
    }

    function saveData() {
        settings.loopthroughfolder = loopfolder.checkedButton
    }

}
