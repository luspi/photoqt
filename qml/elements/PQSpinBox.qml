import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {

    id: control

    editable: true

    property string prefix: ""
    property string suffix: ""

    width: 100
    height: 30

    contentItem: TextInput {
            z: 2
            text: prefix + control.textFromValue(control.value, control.locale) + suffix

            font: control.font
            color: "black"
            selectionColor: "black"
            selectedTextColor: "white"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            readOnly: !control.editable
            validator: control.validator
            inputMethodHints: Qt.ImhDigitsOnly

            onTextChanged:
                control.value = parseInt(text)

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor

                propagateComposedEvents: true
                onClicked: mouse.accepted = false
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false
                onDoubleClicked: mouse.accepted = false
                onPositionChanged: mouse.accepted = false
                onPressAndHold: mouse.accepted = false
                onWheel: {
                    if(wheel.angleDelta.y < 0)
                        control.value = Math.max(control.from, control.value-control.stepSize)
                    else
                        control.value = Math.min(control.to, control.value+control.stepSize)
                }
            }

        }

}
