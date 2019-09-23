import QtQuick 2.9
import Qt.labs.platform 1.0

SystemTrayIcon {

    id: trayicon_top

    visible: PQSettings.trayIcon!=0
    iconSource: "/other/icon.png"

    menu: Menu {
        MenuItem {
            text: "Hide/Show PhotoQt"
            onTriggered: {
                if(PQSettings.trayIcon == 1)
                    toplevel.visible = !toplevel.visible
            }
        }
        MenuItem {
            text: "Quit PhotoQt"
            onTriggered:
                Qt.quit()
        }
    }

    onActivated:
        toplevel.visible = (!toplevel.visible || !(PQSettings.trayIcon == 1 && toplevel.visible))
}
