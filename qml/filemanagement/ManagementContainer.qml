import QtQuick 2.6

Item {
    id: container
    property string category: ""
    property string itemSource: ""
    visible: (opacity!=0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    width: management_top.width-300
    height: management_top.height-250

    signal itemShown()
    signal itemHidden()

    Loader { id: item }

    property bool categorySetUp: false

    onVisibleChanged: {
        if(!categorySetUp && visible) {
            item.source = itemSource
            categorySetUp = true
        }
    }
    onOpacityChanged: {
        if(opacity == 1)
           itemShown()
        else if(opacity == 0)
            itemHidden()
    }

    Connections {
        target: management_top
        onCurrentChanged: {
            if(management_top.current == container.category)
                container.opacity = 1
            else
                container.opacity = 0
        }
    }

}
