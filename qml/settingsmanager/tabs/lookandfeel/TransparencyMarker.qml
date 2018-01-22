import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: Refers to looping through the folder, i.e., from the last image go back to the first one (and vice versa)
            title: em.pty+qsTr("Transparency Marker")
            helptext: em.pty+qsTr("Transparency in image viewers is often signalled by displaying a pattern of light and dark grey squares. PhotoQt can do the same, by default it will, however, show transparent areas as transparent.")

        }

        EntrySetting {

            CustomCheckBox {

                id: transparency
                text: em.pty+qsTr("Show Transparency Marker")

            }

        }

    }

    function setData() {
        transparency.checkedButton = settings.showTransparencyMarkerBackground
    }

    function saveData() {
        settings.showTransparencyMarkerBackground = transparency.checkedButton
    }

}
