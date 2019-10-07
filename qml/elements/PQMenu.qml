import QtQuick 2.9
import QtQuick.Controls 2.2

Menu {

    id: menu

    y: parent.y+parent.height

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        color: "#333333"
        radius: 2
        border.width: 1
        border.color: "#cccccc"
    }

    onContentItemChanged:
        updateWidth()

    function updateWidth() {
        var result = 0;
        var padding = 0;
        for (var i = 0; i < menu.contentModel.count; ++i) {
            var item = itemAt(i);
            result = Math.max(item.contentItem.width, result);
            padding = Math.max(item.padding, padding);
        }
        menu.width = result + padding * 2
    }


}
