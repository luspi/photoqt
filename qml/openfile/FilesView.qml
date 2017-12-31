import QtQuick 2.6
import QtQuick.Layouts 1.1

import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    Layout.fillWidth: true

    color: (openvariables.currentFocusOn=="filesview") ? "#44000055" : "#44000000"

}
