import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Visibility")
            helptext: qsTr("The thumbnails normally fade out when not needed, however, they can be set to stay visible. The big image is shrunk to fit into the empty space. Note, that the thumbnails will be hidden (and only shown on mouse hovering) once you zoomed the image in/out. Resetting the zoom restores the original visibility of the thumbnails.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {

                id: keepvisible

                // Checkbox in settings manager, thumbnails tab
                text: qsTr("Keep thumbnails visible, don't hide them past screen edge")

            }

        }

    }

    function setData() {
        keepvisible.checkedButton = settings.thumbnailKeepVisible
    }

    function saveData() {
        settings.thumbnailKeepVisible = keepvisible.checkedButton
    }

}
