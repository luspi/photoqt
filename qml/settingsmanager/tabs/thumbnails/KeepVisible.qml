import QtQuick 2.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: Settings title: Keep the thumbnails permanently visible
            title: qsTr("Visibility")
            helptext: qsTr("Per default the Thumbnails slide out over the edge of the screen. Here you can force them to stay visible. The big image is shrunk to fit into the empty space. Note, that the thumbnails will be hidden (and only shown on mouse hovering) once you zoomed the image in/out. Resetting the zoom restores the original visibility of the thumbnails.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {

                id: keepvisible

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
