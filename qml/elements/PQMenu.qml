import QtQuick 2.9
import QtQuick.Controls 2.2

Menu {

    id: menu

    y: parent.y+parent.height

    width: {
        var result = 0;
        var padding = 0;
        for (var i = 0; i < count; ++i) {
            var item = itemAt(i);
            result = Math.max(item.contentItem.implicitWidth, result);
            padding = Math.max(item.padding, padding);
        }
        return result + padding * 2;
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: "#333333"
        radius: 2
        border.width: 1
        border.color: "#cccccc"
    }


}
