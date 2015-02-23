import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

ComboBox {

    property int fontsize: 10

    style: ComboBoxStyle {
        background: Rectangle {
            color: "#88000000"
            border.width: 1
            border.color: "#404040"
            implicitWidth: 100
        }
        label: Text {
            id: txt
            font.pointSize: fontsize
            text: control.currentText
            color: "white"
        }

        // Undocumented and unofficial way to style dropdown menu
        // Found at: http://qt-project.org/forums/viewthread/33188

        // drop-down customization here
        property Component __dropDownStyle: MenuStyle {

            __maxPopupHeight: 600
            __menuItemType: "comboboxitem"

            // background
            frame: Rectangle {
                color: "#bb000000"
                border.width: 1
                border.color: "#404040"
            }

            // an item text
            itemDelegate.label:
                Text {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: fontsize
                color: styleData.selected ? "black" : "white"
                text: styleData.text
            }

            // selection of an item
            itemDelegate.background: Rectangle {
                radius: 2
                color: styleData.selected ? "white" : "black"
            }

            __scrollerStyle: ScrollViewStyle { }

        }

    }

}
