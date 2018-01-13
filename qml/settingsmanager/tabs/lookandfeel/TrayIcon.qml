import QtQuick 2.4
import QtQuick.Controls 1.3

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: qsTr("Hide to Tray Icon")
            helptext: qsTr("PhotoQt can make use of a tray icon in the system tray. It can also hide to the system tray when closing it instead of quitting. It is also possible to start PhotoQt already minimised to the tray (e.g. at system startup) when called with \"--start-in-tray\".")

        }

        EntrySetting {

            Row {

                spacing: 10

                ExclusiveGroup { id: tray; }

                CustomRadioButton {
                    id: tray_one
                    //: The tray icon is the icon in the system tray
                    text: qsTr("No tray icon")
                    exclusiveGroup: tray
                    checked: true
                }
                CustomRadioButton {
                    id: tray_two
                    //: The tray icon is the icon in the system tray
                    text: qsTr("Hide to tray icon")
                    exclusiveGroup: tray
                }
                CustomRadioButton {
                    id: tray_three
                    //: The tray icon is the icon in the system tray
                    text: qsTr("Show tray icon, but don't hide to it")
                    exclusiveGroup: tray
                }

            }

        }

    }

    function setData() {
        if(settings.trayicon == 0)
            tray_one.checked = true
        else if(settings.trayicon == 1)
            tray_two.checked = true
        else if(settings.trayicon == 2)
            tray_three.checked = true
    }

    function saveData() {
        if(tray_one.checked)
            settings.trayicon = 0
        else if(tray_two.checked)
            settings.trayicon = 1
        else if(tray_three.checked)
            settings.trayicon = 2
    }

}
