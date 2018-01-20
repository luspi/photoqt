import QtQuick 2.5

Item {
    id: container
    property string category: ""
    property string itemSource: ""
    visible: (opacity!=0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    width: management_top.width-300
    height: management_top.height-250

    signal itemShown()
    signal itemHidden()

    Loader { id: item }

    property bool categorySetUp: false

    onOpacityChanged: {
        if(opacity != 0)
           itemShown()
        else if(opacity == 0)
            itemHidden()
    }

    Connections {
        target: management_top
        onCurrentChanged: {
            if(management_top.current == container.category) {
                container.opacity = 1
                if(!categorySetUp) {
                    item.source = itemSource
                    categorySetUp = true
                }
            } else
                container.opacity = 0
        }
        onVisibleChanged:
            container.opacity = (management_top.visible&&management_top.current==category ? 1 : 0)
    }

}
