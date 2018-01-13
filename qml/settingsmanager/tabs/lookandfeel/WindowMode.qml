import QtQuick 2.5

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Window Mode")
            helptext: qsTr("PhotoQt can be used both in fullscreen mode or as a normal window. It was designed with a fullscreen/maximised application in mind, thus it will look best when used that way, but will work just as well any other way.")

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
