import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Disable thumbnails")
            helptext: em.pty+qsTr("If you just don't need or don't want any thumbnails whatsoever, then you can disable them here completely. This will increase the speed of PhotoQt, but will make navigating with the mouse harder.")

        }

        EntrySetting {

            id: entry

            CustomCheckBox {

                id: disable
                text: em.pty+qsTr("Disable Thumbnails altogether")

            }

        }

    }

    function setData() {
        disable.checkedButton = settings.thumbnailDisable
    }

    function saveData() {
        settings.thumbnailDisable = disable.checkedButton
    }

}
