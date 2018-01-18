import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Visibility")
            helptext: qsTr("The thumbnails normally fade out when not needed, however, they can be set to stay visible. The main image is shrunk to fit into the free space. When it is zoomed in the thumbnails can be set to fade out automatically.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 10

                CustomCheckBox {

                    id: keepvisible

                    // Checkbox in settings manager, thumbnails tab
                    text: qsTr("Keep thumbnails visible, don't hide them past screen edge")

                    onCheckedButtonChanged: {
                        if(checkedButton)
                            keepvisiblewhennotzoomedin.checkedButton = false
                    }

                }

                CustomCheckBox {

                    id: keepvisiblewhennotzoomedin

                    // Checkbox in settings manager, thumbnails tab
                    text: qsTr("Keep thumbnails visible as long as the main image is not zoomed in")

                    onCheckedButtonChanged: {
                        if(checkedButton)
                            keepvisible.checkedButton = false
                    }

                }

            }

        }

    }

    function setData() {
        keepvisible.checkedButton = settings.thumbnailKeepVisible
        keepvisiblewhennotzoomedin.checkedButton = settings.thumbnailKeepVisibleWhenNotZoomedIn
    }

    function saveData() {
        settings.thumbnailKeepVisible = keepvisible.checkedButton
        settings.thumbnailKeepVisibleWhenNotZoomedIn = keepvisiblewhennotzoomedin.checkedButton
    }

}
