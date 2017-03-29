import QtQuick 2.4

Rectangle {

    id: item_top

    property bool alternating: false

    color: alternating ? "#08ffffff" : "transparent"
    width: flickable.width
    height: childrenRect.height+30

}
