import QtQuick 2.6
import QtQuick.Layouts 1.1

import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openFoldersWidth
    onWidthChanged: saveFolderWidth.start()

    color: openvariables.currentFocusOn=="folders" ? "#44000055" : "#44000000"

    Timer {
        id: saveFolderWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openFoldersWidth = width
    }

}
