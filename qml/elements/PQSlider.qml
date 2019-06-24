import QtQuick 2.9
import QtQuick.Controls 2.2

Slider {

    id: control

    orientation: Qt.Horizontal

    stepSize: 1.0

    hoverEnabled: true

    property int divideToolTipValue: 1
    property alias tooltip: slidertooltip.text
    property string handleToolTipPrefix: ""
    property string handleToolTipSuffix: ""

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#565656"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#eeeeee"
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
    }

    PQToolTip {
        id: handletooltip
        parent: control.handle
        visible: control.pressed
        delay: 0
        text: handleToolTipPrefix + (control.value/divideToolTipValue) + handleToolTipSuffix
    }

    PQToolTip {
        id: slidertooltip
        parent: control
        visible: control.hovered&&!handletooltip.visible&&text!=""
        delay: 500
    }

}
