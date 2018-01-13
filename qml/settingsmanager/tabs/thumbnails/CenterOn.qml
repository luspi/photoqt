import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: the center is the center of the screen edge. The thing talked about are the thumbnails.
            title: qsTr("Keep in Center")
            helptext: qsTr("If this option is set, then the current thumbnail (i.e., the thumbnail of the currently displayed image) will always be kept in the center of the thumbnail bar (if possible). If this option is not set, then the active thumbnail will simply be kept visible, but not necessarily in the center.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {
                id: centeron
                text: qsTr("Center on Current Thumbnail")
            }

        }

    }

    function setData() {
        centeron.checkedButton = settings.thumbnailCenterActive
    }

    function saveData() {
        settings.thumbnailCenterActive = centeron.checkedButton
    }

}
