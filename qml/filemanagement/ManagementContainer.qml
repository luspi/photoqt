import QtQuick 2.6

Rectangle {
    id: container
    property string category: ""
    property string itemSource: ""
    visible: (opacity!=0)
    opacity: management_top.current==category ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    width: management_top.width-300
    height: management_top.height-250

    Loader { id: item }

    property bool categorySetUp: false

    onVisibleChanged: {
        if(!categorySetUp && visible) {
            item.source = itemSource
            categorySetUp = true
        }
    }

}
