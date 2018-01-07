import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openUserPlacesWidth
    onWidthChanged: saveUserPlacesWidth.start()

    color: openvariables.currentFocusOn=="userplaces" ? "#44000055" : "#44000000"

    property int marginBetweenCategories: 20

    property alias userPlacesModel: userPlaces.model
    property alias storageInfoModel: storageinfo.model

    clip: true

    Timer {
        id: saveUserPlacesWidth
        interval: 250
        repeat: false
        running: false
        onTriggered:
            settings.openUserPlacesWidth = width
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        onClicked: headingmenu.popup()
    }

    ListView {
        id: standardlocations
        y: settings.openUserPlacesStandard ? marginBetweenCategories : 0
        width: parent.width
        height: settings.openUserPlacesStandard ? childrenRect.height : 0

        visible: settings.openUserPlacesStandard
        interactive: false

        property int hoveredIndex: -1

        model: ListModel {
            Component.onCompleted: {
                append({"name" : "",
                        "location" : "",
                        "icon" : ""})
                append({"name" : "Home",
                        "location" : getanddostuff.getHomeDir(),
                        "icon" : "user-home"})
                append({"name" : "Desktop",
                        "location" : getanddostuff.getDesktopDir(),
                        "icon" : "user-desktop"})
                append({"name" : "Pictures",
                        "location" : getanddostuff.getPicturesDir(),
                        "icon" : "folder-pictures"})
                append({"name" : "Downloads",
                        "location" : getanddostuff.getDownloadsDir(),
                        "icon" : "folder-download"})
            }
        }

        delegate: Item {

            id: standarddeleg
            width: standardlocations.width
            height: 30

            Rectangle {
                width: standardlocations.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: standardlocations.hoveredIndex==index&&index>0 ? "#88999999" : index%2==0 ? "#88000000" : "#44000000"

                Item {
                    id: iconitem
                    width: parent.height
                    height: width
                    Image {
                        source: "image://icon/" + icon
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: index>0
                    }

                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: iconitem.width
                    verticalAlignment: Qt.AlignVCenter
                    text: index==0 ? "Standard" : name
                    color: index==0 ? "grey" : "white"
                    font.bold: index==0
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: standardlocations.hoveredIndex = index
                    onExited: standardlocations.hoveredIndex = -1
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: openvariables.currentDirectory = location
                }

            }

        }
    }

    ListView {
        id: userPlaces
        anchors.top: standardlocations.bottom
        anchors.topMargin: marginBetweenCategories
        width: parent.width
        height: parent.height-standardlocations.height-storageinfo.height-4*marginBetweenCategories
        anchors.right: parent.right

        property int hoveredIndex: -1
        property int dragItemIndex: -1

        clip: true

        DropArea {
            id: dropArea
            anchors.fill: parent
            onDropped: {
                var newindex = userPlaces.indexAt(drag.x, drag.y)
                if(newindex==0) newindex = 1
                if(splitview.dragSource == "folders") {
                    if(newindex != -1)
                        userPlaces.model.insert(newindex, folders.folderlistview.model.get(folders.folderlistview.dragItemIndex))
                    else
                        userPlaces.model.append(folders.folderlistview.model.get(folders.folderlistview.dragItemIndex))
                    Handle.saveUserPlaces()
                } else {
                    if(newindex < 0) newindex = userPlaces.model.count-1
                    userPlaces.model.move(userPlaces.dragItemIndex, newindex, 1)
                    Handle.saveUserPlaces()
                }
                folders.folderlistview.dragItemIndex = -1
                splitview.hoveringOver = -1
            }
            onPositionChanged: {
                var newindex = userPlaces.indexAt(drag.x, drag.y)
                if(newindex == -1)
                    newindex = userPlaces.model.count
                splitview.hoveringOver = newindex
            }
            onExited: splitview.hoveringOver = -1
        }

        model: ListModel {
            Component.onCompleted: {
                Handle.loadUserPlaces()
            }
        }

        delegate: Item {
            id: userPlacesDelegate
            width: userPlaces.width
            height: visible?30:0
            visible: ((path!=undefined&&path.substring(0,1)=="/"&&hidden=="false")||index==0)

            Rectangle {
                width: userPlaces.width
                height: 1
                color: "white"
                opacity: (splitview.hoveringOver==index&&index>0)||(splitview.hoveringOver==index-1&&index==1) ? 1 : 0
                visible: opacity!=0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            Rectangle {
                id: dragRect
                width: userPlaces.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: userPlaces.hoveredIndex==index&&index>0 ? "#88999999" : index%2==0 ? "#88000000" : "#44000000"

                Item {
                    id: draghandler
                    width: dragRect.height
                    height: width
                    Image {
                        source: "image://icon/" + icon
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: index>0
                    }

                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: draghandler.width
                    verticalAlignment: Qt.AlignVCenter
                    text: index==0 ? "Places" : (folder != undefined ? folder : "")
                    color: index==0 ? "grey" : "white"
                    font.bold: index==0
                    elide: Text.ElideMiddle
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                    onEntered: userPlaces.hoveredIndex = index
                    onExited: userPlaces.hoveredIndex = -1
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if(mouse.button == Qt.LeftButton)
                            openvariables.currentDirectory = path
                        else
                            delegcontext.popup()
                    }
                }

                ContextMenu {
                    id: delegcontext
                    MenuItem {
                        text: "Remove entry"
                        onTriggered: {
                            userPlaces.model.remove(index)
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: draghandler
                    drag.target: dragRect
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor

                    drag.onActiveChanged: {
                        if (mouseArea.drag.active) {
                            userPlaces.dragItemIndex = index;
                            splitview.dragSource = "userplaces"
                        }
                        dragRect.Drag.drop();
                    }

                    onEntered: userPlaces.hoveredIndex = index
                    onExited: userPlaces.hoveredIndex = -1
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
                Drag.hotSpot.x: dragRect.width / 3
                Drag.hotSpot.y: 10

            }

            Rectangle {
                width: userPlaces.width
                anchors.top: dragRect.bottom
                height: 1
                opacity: (splitview.hoveringOver==index&&index>0)||(splitview.hoveringOver==index+1&&index==userPlaces.model.count-1)
                visible: opacity!=0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

        }
    }

    ListView {
        id: storageinfo
        anchors.top: userPlaces.bottom
        width: parent.width
        height: settings.openUserPlacesStandard ? childrenRect.height : 0

        visible: settings.openUserPlacesStandard
        interactive: false

        property int hoveredIndex: -1

        model: ListModel {
            Component.onCompleted: {
                Handle.loadStorageInfo()
            }
        }

        delegate: Item {

            width: storageinfo.width
            height: 30

            Rectangle {
                width: storageinfo.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: storageinfo.hoveredIndex==index&&index>0 ? "#88999999" : index%2==0 ? "#88000000" : "#44000000"

                Item {
                    id: iconitemstorage
                    width: parent.height
                    height: width
                    Image {
                        source: "image://icon/" + icon
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: index>0
                    }

                }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: iconitemstorage.width
                    verticalAlignment: Qt.AlignVCenter
                    text: index==0 ? "Storage devices" : (name!=undefined ? name : "")
                    color: index==0 ? "grey" : "white"
                    font.bold: index==0
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: storageinfo.hoveredIndex = index
                    onExited: storageinfo.hoveredIndex = -1
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: openvariables.currentDirectory = location
                }

            }

        }
    }

    ContextMenu {

        id: headingmenu

        MenuItem {
            id: visiblestandard
            checkable: true
            checked: settings.openUserPlacesStandard
            onCheckedChanged:
                settings.openUserPlacesStandard = checked
            //: OpenFile: This refers to standard folders for pictures, etc.
            text: qsTr("Show standard locations")
        }
        MenuItem {
            id: visibleuser
            checkable: true
            checked: settings.openUserPlacesUser
            onCheckedChanged:
                settings.openUserPlacesUser = checked
            //: OpenFile: This refers to the user-set folders
            text: qsTr("Show user locations")
        }
        MenuItem {
            id: visiblevolumes
            checkable: true
            checked: settings.openUserPlacesVolumes
            onCheckedChanged:
                settings.openUserPlacesVolumes = checked
            //: OpenFile: This refers to connected devices (harddrives, partitions, etc.)
            text: qsTr("Show devices")
        }

    }

}
