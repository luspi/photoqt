import QtQuick 2.6
import QtQuick.Layouts 1.1

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openFoldersWidth
    onWidthChanged: saveFolderWidth.start()

    property alias folderlistview: listView

    color: openvariables.currentFocusOn=="folders" ? "#44000055" : "#44000000"

    Timer {
        id: saveFolderWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openFoldersWidth = width
    }

    ListView {
        id: listView
        width: parent.width
        height: parent.height

        property int dragItemIndex: -1
        property int hoveredIndex: -1

        Text {
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            text: "No subfolders"
            font.bold: true
            color: "grey"
            font.pointSize: 20
            visible: (opacity!=0)
            opacity: listView.model.count==1 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }

        model: ListModel { }

        delegate: Item {
            id: delegateItem
            width: listView.width
            height: settings.openZoomLevelSet*5

            Rectangle {
                id: dragRect
                width: listView.width
                height: settings.openZoomLevelSet*5
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: listView.hoveredIndex==index ? "#88999999" : index%2==0 ? "#88000000" : "#44000000"
                Behavior on color { ColorAnimation { duration: 100 } }

                Item {
                    id: draghandler
                    width: dragRect.height
                    height: width
                    Image {
                        source: "image://icon/folder"
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: index>0
                    }

                }

                Text {
                    id: foldertxt
                    anchors {
                        left: draghandler.right
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }

                    anchors.margins: settings.openZoomLevelSet*2
                    verticalAlignment: Qt.AlignVCenter
                    text: "<b>" + folder + "</b>" + ((counter==0||folder=="..") ? "" : " <i>(" + counter + " images)</i>")
                    color: "white"
                    font.pixelSize: settings.openZoomLevelSet*3
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: listView.hoveredIndex = index
                    onExited: listView.hoveredIndex = -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openvariables.currentDirectory = path

                    drag.target: index>0?dragRect:undefined

                    drag.onActiveChanged: {
                        if (mouseArea.drag.active) {
                            listView.dragItemIndex = index;
                            splitview.dragSource = "folders"
                        }
                        dragRect.Drag.drop();
                    }
                }

                states: [
                    State {
                        when: dragRect.Drag.active
                        ParentChange {
                            target: dragRect
                            parent: splitview
                        }

                        AnchorChanges {
                            target: dragRect
                            anchors.horizontalCenter: undefined
                            anchors.verticalCenter: undefined
                        }
                    }
                ]

                Drag.active: mouseArea.drag.active
                Drag.hotSpot.x: draghandler.width/2
                Drag.hotSpot.y: 10
            }
        }
    }

    ScrollBarVertical {
        id: listview_scrollbar
        flickable: listView
        opacityVisible: 0.8
        opacityHidden: 0.8
    }

}
