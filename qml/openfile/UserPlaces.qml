import QtQuick 2.6
import QtQuick.Layouts 1.1

import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openUserPlacesWidth
    onWidthChanged: saveUserPlacesWidth.start()

    color: openvariables.currentFocusOn=="userplaces" ? "#44000055" : "#44000000"

    Timer {
        id: saveUserPlacesWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openUserPlacesWidth = width
    }

}
