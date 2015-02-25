import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

SpinBox {

    style: SpinBoxStyle{
            background: Rectangle {
                implicitWidth: 50
                implicitHeight: 20
                color: "#88000000"
                border.color: "#99969696"
                radius: 2
            }
            textColor: "white"
            selectionColor: "white"
            selectedTextColor: "black"
            decrementControl: Text {
                color: "white"
                y: -height*2/3
                font.pixelSize: control.height
                text: "-"
            }
            incrementControl: Text {
                color: "white"
                y: -height*2/3
                font.pixelSize: control.height
                text: "+"
            }
        }

}
