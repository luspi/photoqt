import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            //: The hot edge refers to the left and right screen edge (here in particular only to the left one). When the mouse cursor enters the hot edge area, then the metadata element is shown
            title: qsTr("Enable 'Hot Edge'")
            helptext: qsTr("Per default the info widget can be shown two ways: Moving the mouse cursor to the left screen edge to fade it in temporarily (as long as the mouse is hovering it), or permanently by clicking the checkbox (checkbox only stored per session, can't be saved permanently!). Alternatively the widget can also be triggered by shortcut or main menu item. On demand the mouse triggering can be disabled, so that the widget would only show on shortcut/menu item.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {

                id: triggeronmouse
                text: qsTr("DISable Hot Edge")

            }

        }

    }

    function setData() {
        triggeronmouse.checkedButton = settings.exifenablemousetriggering
    }

    function saveData() {
        settings.exifenablemousetriggering = triggeronmouse.checkedButton
    }

}
