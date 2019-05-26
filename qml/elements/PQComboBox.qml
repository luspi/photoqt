import QtQuick 2.9
import QtQuick.Controls 2.2

ComboBox {
    id: control

    property alias tooltip: combomousearea.tooltip
    property alias tooltipFollowsMouse: combomousearea.tooltipFollowsMouse

    delegate: ItemDelegate {
        id: controldelegate
        width: control.width
        contentItem: Text {
            text: modelData
            color: "white"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            opacity: enabled ? 1 : 0.3
            color: (controldelegate.down||controldelegmouse.containsMouse) ? "#ff000000" : "#cc444444"
        }

        MouseArea {
            id: controldelegmouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: true
            hoverEnabled: true
            onClicked: controldelegate.clicked()
            onPressed: controldelegate.down = true
            onReleased: controldelegate.down = false
        }

    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? "#cccccc" : "#ffffff";
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        color: control.pressed ? "#cccccc" : "#ffffff"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.pressed ? "#cc000000" : "#cc444444"
        border.color: control.pressed ? "#cc222222" : "#cc666666"
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }



    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
        }

        background: Rectangle {
            color: "#cc444444"
            border.color: "#cc666666"
            radius: 2
        }
    }

    PQMouseArea {
        id: combomousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if(control.popup.opened)
                control.popup.close()
            else
                control.popup.open()
        }
    }
}
