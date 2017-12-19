import QtQuick 2.6

Text {
    text: ""
    property string category: ""
    font.pointSize: 30
    font.bold: true
    color: (active||management_top.current==category) ? colorActive : colorInactive
    Behavior on color { ColorAnimation { duration: 100 } }

    property string colorActive: colour.text
    property string colorInactive: colour.text_disabled
    property bool active: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: active = true
        onExited: active = false
        onClicked:
            management_top.current = category
    }

}
