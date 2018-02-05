import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            title: em.pty+qsTr("Hide to Tray Icon")
            helptext: em.pty+qsTr("PhotoQt can make use of a tray icon in the system tray. It can also hide to the system tray when closing it instead of quitting. It is also possible to start PhotoQt already minimised to the tray (e.g. at system startup) when called with \"--start-in-tray\".")

        }

        EntrySetting {

            Row {

                spacing: 10

                ExclusiveGroup { id: tray; }

                CustomRadioButton {
                    id: tray_one
                    //: The tray icon is the icon in the system tray
                    text: em.pty+qsTr("No tray icon")
                    exclusiveGroup: tray
                    checked: true
                }
                CustomRadioButton {
                    id: tray_two
                    //: The tray icon is the icon in the system tray
                    text: em.pty+qsTr("Hide to tray icon")
                    exclusiveGroup: tray
                }
                CustomRadioButton {
                    id: tray_three
                    //: The tray icon is the icon in the system tray
                    text: em.pty+qsTr("Show tray icon, but don't hide to it")
                    exclusiveGroup: tray
                }

            }

        }

    }

    function setData() {
        if(settings.trayIcon === 0)
            tray_one.checked = true
        else if(settings.trayIcon === 1)
            tray_two.checked = true
        else if(settings.trayIcon === 2)
            tray_three.checked = true
    }

    function saveData() {
        if(tray_one.checked)
            settings.trayIcon = 0
        else if(tray_two.checked)
            settings.trayIcon = 1
        else if(tray_three.checked)
            settings.trayIcon = 2
    }

}
