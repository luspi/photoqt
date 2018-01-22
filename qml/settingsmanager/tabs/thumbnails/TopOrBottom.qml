import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: Refers to the top and bottom screen edges
            title: em.pty+qsTr("Top or Bottom")
            helptext: em.pty+qsTr("Per default the bar with the thumbnails is shown at the lower screen edge. However, some might find it nice and handy to have the thumbnail bar at the upper edge.")

        }

        EntrySetting {

            id: entry

            Row {

                spacing: 10

                ExclusiveGroup { id: edgegroup; }

                CustomRadioButton {
                    id: loweredge
                    //: Edge refers to a screen edge
                    text: em.pty+qsTr("Show at lower edge")
                    checked: true
                    exclusiveGroup: edgegroup
                }

                CustomRadioButton {
                    id: upperedge
                    //: Edge refers to a screen edge
                    text: em.pty+qsTr("Show at upper edge")
                    exclusiveGroup: edgegroup
                }

            }

        }

    }

    function setData() {
        loweredge.checked = (settings.thumbnailPosition !== "Top")
        upperedge.checked = (settings.thumbnailPosition === "Top")
    }

    function saveData() {
        settings.thumbnailPosition = (loweredge.checked ? "Bottom" : "Top")
    }

}
