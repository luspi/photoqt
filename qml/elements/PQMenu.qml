import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

Popup {

    id: control

    property var model: []
    property var hideIndices: []
    property var lineBelowIndices: []

    padding: 1
    margins: 0

    signal triggered(var index)

    property int maxWidth: 100

    property int leftrightpadding: 5

    background: Rectangle {
        color: "transparent"
        border.width: 1
        border.color: "#aaaaaa"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: control.model.length
            Rectangle {
                implicitWidth: control.maxWidth
                implicitHeight: 30
                property bool mouseOver: false
                visible: (hideIndices.indexOf(index)==-1)
                opacity: enabled ? 1 : 0.3
                color: mouseOver ? "#aaaaaa" : "#cc111111"
                Behavior on color { ColorAnimation { duration: 200 } }
                Text {
                    x: leftrightpadding
                    y: (parent.height-height)/2
                    text: control.model[index]
                    font: control.font
                    opacity: enabled ? 1.0 : 0.3
                    color: parent.mouseOver ? "#111111" : "#aaaaaa"
                    Behavior on color { ColorAnimation { duration: 200 } }
                    horizontalAlignment: Text.AlignLeft // Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Component.onCompleted:
                        if(width+2*leftrightpadding > control.maxWidth)
                            control.maxWidth = width+2*leftrightpadding
                    onWidthChanged: {
                        if(width+2*leftrightpadding > control.maxWidth)
                            control.maxWidth = width+2*leftrightpadding
                    }
                }
                Rectangle {
                    x: 0
                    y: parent.height-height
                    width: parent.width
                    height: 1
                    color: lineBelowIndices.indexOf(index)==-1 ? "#88555555" : "#cccccc"
                    visible: index < control.model.length-1
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.mouseOver = true
                    onExited: parent.mouseOver = false
                    onClicked: {
                        control.triggered(index)
                        control.close()
                    }
                }
            }
        }

    }

    function popup(pos) {
        control.x = pos.x
        control.y = pos.y
        control.open()
    }

}
