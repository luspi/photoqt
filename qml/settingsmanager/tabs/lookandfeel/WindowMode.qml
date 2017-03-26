import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Window Mode")
            helptext: qsTr("PhotoQt is designed with the space of a fullscreen app in mind. That's why it by default runs as fullscreen. However, some might prefer to have it as a normal window, e.g. so that they can see the panel.")

        }

        EntrySetting {

            Row {

                spacing: 10

                CustomCheckBox {
                    id: windowmode
                    text: qsTr("Run PhotoQt in Window Mode")
                }

                CustomCheckBox {
                    id: windowmode_deco
                    enabled: windowmode.checkedButton
                    text: qsTr("Show Window Decoration")
                }

            }

        }

    }

    function setData() {
        windowmode.checkedButton = settings.windowmode
        windowmode_deco.checkedButton = settings.windowDecoration
    }

    function saveData() {
        settings.windowmode = windowmode.checkedButton
        settings.windowDecoration = windowmode_deco.checkedButton
    }

}
