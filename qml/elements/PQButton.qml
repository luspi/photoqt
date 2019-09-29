import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQml 2.0

Button {
    id: control

    text: ""

    property string backgroundColor: "#333333"
    property string backgroundColorHover: "#3a3a3a"
    property string backgroundColorActive: "#444444"
    property string textColor: "#ffffff"
    property string textColorHover: "#ffffff"
    property string textColorActive: "#ffffff"

    property bool clickOpensMenu: false
    property var listMenuItems: []

    property string imageButtonSource: ""
    property real imageOpacity: 1

    property bool mouseOver: false

    property alias tooltip: mousearea.tooltip
    property alias tooltipFollowsMouse: mousearea.tooltipFollowsMouse

    signal menuItemClicked(var item)

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? control.textColorActive : (control.mouseOver ? control.textColorHover : control.textColor)
        Behavior on color { ColorAnimation { duration: 100 } }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
//        implicitWidth: 100
        color: control.down ? control.backgroundColorActive : (control.mouseOver ? control.backgroundColorHover : control.backgroundColor)
        Behavior on color { ColorAnimation { duration: 100 } }
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        radius: 2

        Image {

            id: iconview

            source: imageButtonSource

            opacity: imageOpacity
            visible: imageButtonSource!=undefined&&imageButtonSource!=""

            sourceSize: Qt.size(30,30)

            x: (parent.width-width)/2
            y: (parent.height-height)/2

        }

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onPressed:
            control.down = true
        onReleased:
            control.down = false
        onClicked: {
            if(clickOpensMenu)
                menu.open()
            else
                control.clicked()
        }
    }

    PQMenu {

        id: menu

        Instantiator {
            id: menuitems
            model: listMenuItems
            delegate: PQMenuItem {
                text: listMenuItems[index]
                onTriggered: control.menuItemClicked(listMenuItems[index])
            }

            onObjectAdded: menu.addItem(object)
            onObjectRemoved: menu.removeItem(object)
        }

    }

}
