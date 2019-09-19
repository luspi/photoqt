import QtQuick 2.9
import QtQuick.Controls 2.2

ScrollBar {
    id: control
    active: true
    orientation: Qt.Vertical

    width: orientation==Qt.Vertical ? 6 : undefined
    height: orientation==Qt.Vertical ? undefined : 6

    contentItem: Rectangle {
        implicitWidth: control.size==1.0 ? 0 : (control.orientation==Qt.Vertical ? 6 : 100)
        implicitHeight: control.size==1.0 ? 0 : (control.orientation==Qt.Vertical ? 100 : 6)
        radius: control.orientation==Qt.Vertical ? width/2 : height/2
        color: control.pressed ? "#eeeeee" : "#aaaaaa"
        visible: !(control.size==1.0)
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    background: Rectangle {
        color: control.pressed ? "#88888888" : "#88666666"
        visible: control.size<1.0
        Behavior on color { ColorAnimation { duration: 100 } }
    }

}
