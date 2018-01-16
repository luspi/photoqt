import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4

import "../elements"
import "handlestuff.js" as Handle

Rectangle {

    Layout.minimumWidth: 200
    width: settings.openUserPlacesWidth
    onWidthChanged: saveUserPlacesWidth.start()

    color: openvariables.currentFocusOn=="userplaces" ? "#44000055" : "#44000000"

    property int marginBetweenCategories: 20

    property alias userPlacesView: userPlaces
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

        highlightMoveDuration: 100
        highlightResizeDuration: 100

        onCurrentIndexChanged:
            handleChangeCurrentIndex("standard")

        model: ListModel {
            Component.onCompleted: {
                append({"name" : "",
                        "location" : "",
                        "icon" : ""})
                //: This is used as name of the HOME folder
                append({"name" : qsTr("Home"),
                        "location" : getanddostuff.getHomeDir(),
                        "icon" : "user-home"})
                //: This is used as name of the DESKTOP folder
                append({"name" : qsTr("Desktop"),
                        "location" : getanddostuff.getDesktopDir(),
                        "icon" : "user-desktop"})
                //: This is used as name of the PICTURES folder
                append({"name" : qsTr("Pictures"),
                        "location" : getanddostuff.getPicturesDir(),
                        "icon" : "folder-pictures"})
                //: This is used as name of the DOWNLOADS folder
                append({"name" : qsTr("Downloads"),
                        "location" : getanddostuff.getDownloadsDir(),
                        "icon" : "folder-download"})
            }
        }

        highlight: Rectangle {
            width: userPlaces.width
            height: 30
            color: "#88ffffff"
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
                color: index%2==0 ? "#88000000" : "#44000000"
                Behavior on color { ColorAnimation { duration: 100 } }

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
                    //: This is the category title of standard/common folders (like Home, Desktop, ...) in the element for opening files
                    text: index==0 ? qsTr("Standard") : name
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: standardlocations.currentIndex = index
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
        height: settings.openUserPlacesUser ? parent.height-standardlocations.height-storageinfo.height-3*marginBetweenCategories : 0
        anchors.right: parent.right

        visible: settings.openUserPlacesUser

        highlightMoveDuration: 100
        highlightResizeDuration: 100

        property int dragItemIndex: -1

        onCurrentIndexChanged:
            handleChangeCurrentIndex("userplaces")

        clip: true

        DropArea {
            id: dropArea
            anchors.fill: parent
            onDropped: {
                var newindex = userPlaces.indexAt(drag.x, drag.y)
                if(newindex==0) newindex = 1
                if(splitview.dragSource == "folders") {
                    if(newindex != -1)
                        userPlaces.model.insert(newindex, folders.folderListView.model.get(folders.folderListView.dragItemIndex))
                    else
                        userPlaces.model.append(folders.folderListView.model.get(folders.folderListView.dragItemIndex))
                    Handle.saveUserPlaces()
                } else {
                    if(newindex < 0) newindex = userPlaces.model.count-1
                    if(userPlaces.dragItemIndex != newindex) {
                        userPlaces.model.move(userPlaces.dragItemIndex, newindex, 1)
                        Handle.saveUserPlaces()
                    }
                }
                folders.folderListView.dragItemIndex = -1
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

        highlight: Rectangle {
            width: userPlaces.width
            height: 30
            color: "#88ffffff"
        }

        delegate: Item {
            id: userPlacesDelegate
            width: userPlaces.width
            height: visible?30:0
            visible: notvisible=="0"
            Component.onCompleted:
                notvisible = (((path!=undefined&&hidden=="false")||index==0) ? "0" : "1")

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
                color: index%2==0 ? "#88000000" : "#44000000"
                Behavior on color { ColorAnimation { duration: 100 } }

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
                    //: This is the category title of user set folders (or favorites) in the element for opening files
                    text: index==0 ? qsTr("Places") : (folder != undefined ? folder : "")
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    elide: Text.ElideRight
                    font.pixelSize: 15
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                    onEntered: userPlaces.currentIndex = index
                    cursorShape: index>0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: index>0
                    onClicked: {
                        if(mouse.button == Qt.LeftButton)
                            openvariables.currentDirectory = path
                        else
                            delegcontext.popup()
                    }
                    drag.target: dragRect
                    drag.onActiveChanged: {
                        if (mouseArea.drag.active) {
                            userPlaces.dragItemIndex = index;
                            splitview.dragSource = "userplaces"
                        }
                        dragRect.Drag.drop();
                    }
                }

                ContextMenu {
                    id: delegcontext
                    MenuItem {
                        //: Remove an entry from the list of user places (or favorites) in the element for opening files
                        text: qsTr("Remove entry")
                        onTriggered: {
                            userPlaces.model.remove(index)
                        }
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

    ScrollBarVertical {
        id: listview_scrollbar
        flickable: userPlaces
        opacityVisible: 0.8
        opacityHidden: 0.8
    }

    ListView {
        id: storageinfo
        anchors.top: userPlaces.bottom
        width: parent.width
        height: settings.openUserPlacesVolumes ? childrenRect.height : 1

        visible: settings.openUserPlacesVolumes
        interactive: false

        highlightMoveDuration: 100
        highlightResizeDuration: 100

        onCurrentIndexChanged:
            handleChangeCurrentIndex("storage")

        model: ListModel {
            Component.onCompleted: {
                Handle.loadStorageInfo()
            }
        }

        highlight: Rectangle {
            width: userPlaces.width
            height: 30
            color: "#88ffffff"
        }

        delegate: Item {

            width: storageinfo.width
            height: 30

            Rectangle {
                width: storageinfo.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: index%2==0 ? "#88000000" : "#44000000"
                Behavior on color { ColorAnimation { duration: 100 } }

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
                    //: This is the category title of storage devices to open (like USB keys) in the element for opening files
                    text: index==0 ? qsTr("Storage devices") : (name!=undefined ? name : "")
                    color: index==0 ? "grey" : "white"
                    font.bold: true
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: storageinfo.currentIndex = index
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
            //: The standard/common folders (like Home, Desktop, ...)
            text: qsTr("Show standard locations")
        }
        MenuItem {
            id: visibleuser
            checkable: true
            checked: settings.openUserPlacesUser
            onCheckedChanged:
                settings.openUserPlacesUser = checked
            //: The user set folders (or favorites) in the element for opening files
            text: qsTr("Show user locations")
        }
        MenuItem {
            id: visiblevolumes
            checkable: true
            checked: settings.openUserPlacesVolumes
            onCheckedChanged:
                settings.openUserPlacesVolumes = checked
            //: The storage devices (like USB keys)
            text: qsTr("Show devices")
        }

    }

    Connections {
        target: openfile_top
        onHighlightEntry:
            highlightEntry(distance)
        onHighlightFirst:
            highlightFirst()
        onHighlightLast:
            highlightLast()
        onLoadEntry:
            loadHighlightedItem()
    }

    function handleChangeCurrentIndex(source) {

        if(source == "standard") {
            if(standardlocations.currentIndex == -1) return
            if(standardlocations.currentIndex == 0)
                standardlocations.currentIndex = 1
            userPlaces.currentIndex = -1
            storageinfo.currentIndex = -1
            openvariables.currentFocusOn = "userplaces"
        } else if(source == "userplaces") {
            if(userPlaces.currentIndex == -1) return
            if(userPlaces.currentIndex == 0)
                userPlaces.currentIndex = 1
            standardlocations.currentIndex = -1
            storageinfo.currentIndex = -1
            openvariables.currentFocusOn = "userplaces"
        } else if(source == "storage") {
            if(storageinfo.currentIndex == -1) return
            if(storageinfo.currentIndex == 0)
                storageinfo.currentIndex = 1
            standardlocations.currentIndex = -1
            userPlaces.currentIndex = -1
            openvariables.currentFocusOn = "userplaces"
        }

    }

    function highlightFirst() {
        if(standardlocations.visible)
            standardlocations.currentIndex = 1
        else if(userPlaces.visible && userPlaces.model.count > 1)
            userPlaces.currentIndex = 1
        else if(storageinfo.visible && storageinfo.model.count > 1)
            storageinfo.currentIndex = 1
    }

    function highlightLast() {
        if(storageinfo.visible && storageinfo.model.count > 1)
            storageinfo.currentIndex = storageinfo.model.count-1
        else if(userPlaces.visible && userPlaces.model.count > 1)
            userPlaces.currentIndex = userPlaces.model.count-1
        else if(standardlocations.visible)
            standardlocations.currentIndex = standardlocations.model.count-1
    }

    function highlightEntry(distance) {

        if(openvariables.currentFocusOn != "userplaces") return

        if(distance > 0) {

            // move from standard to userplaces
            if(standardlocations.currentIndex != -1 && userPlaces.visible && standardlocations.currentIndex+distance > standardlocations.model.count-1) {
                userPlaces.currentIndex = Math.min(1 + ((standardlocations.currentIndex+distance) - standardlocations.model.count), userPlaces.model.count-1)
                return
            }

            // move from standard to storageinfo
            if(standardlocations.currentIndex != -1 && !userPlaces.visible && storageinfo.visible && standardlocations.currentIndex+distance > standardlocations.model.count-1) {
                storageinfo.currentIndex = Math.min(1 + ((standardlocations.currentIndex+distance) - standardlocations.model.count), storageinfo.model.count-1)
                return
            }

            // move from userplaces to storageinfo
            if(userPlaces.currentIndex != -1 && storageinfo.visible && userPlaces.currentIndex+distance > userPlaces.model.count-1) {
                storageinfo.currentIndex = Math.min(1 + ((userPlaces.currentIndex+distance) - userPlaces.model.count), storageinfo.model.count)
                return
            }

            // move inside standard
            if(standardlocations.currentIndex != -1) {
                standardlocations.currentIndex = Math.min(standardlocations.currentIndex+distance, standardlocations.model.count-1)
                return
            }

            // move inside userplaces
            if(userPlaces.currentIndex != -1) {
                if(userPlaces.currentIndex == userPlaces.model.count-1)
                    return
                while(distance > 0) {
                    userPlaces.currentIndex += 1
                    if(userPlaces.model.get(userPlaces.currentIndex).notvisible=="0")
                        distance -= 1
                    if(userPlaces.currentIndex == userPlaces.model.count-1)
                        distance = 0
                }
                return
            }

            // move inside storageinfo
            if(storageinfo.currentIndex != -1) {
                storageinfo.currentIndex = Math.min(storageinfo.currentIndex+distance, storageinfo.model.count-1)
                return
            }

        } else {

            distance *= -1

            // move from userplaces to standard
            if(userPlaces.currentIndex != -1 && standardlocations.visible && userPlaces.currentIndex-distance < 1) {
                standardlocations.currentIndex = Math.max(standardlocations.count-1 - (distance-userPlaces.currentIndex), 1)
                return
            }

            // move from storageinfo to standard
            if(storageinfo.currentIndex != -1 && !userPlaces.visible && standardlocations.visible && storageinfo.currentIndex-distance < 1) {
                standardlocations.currentIndex = Math.max(standardlocations.count-1 - (distance-storageinfo.currentIndex), 1)
                return
            }

            // move from storageinfo to userplaces
            if(storageinfo.currentIndex != -1 && userPlaces.visible && storageinfo.currentIndex-distance < 1) {
                userPlaces.currentIndex = Math.max(userPlaces.count-1 - (distance-storageinfo.currentIndex), 1)
                return
            }

            // move inside standard
            if(standardlocations.currentIndex != -1) {
                standardlocations.currentIndex = Math.max(standardlocations.currentIndex-distance, 1)
                return
            }

            // move inside userplaces
            if(userPlaces.currentIndex != -1) {
                while(distance > 0) {
                    userPlaces.currentIndex -= 1
                    if(userPlaces.model.get(userPlaces.currentIndex).notvisible=="0")
                        distance -= 1
                    if(userPlaces.currentIndex == 1)
                        distance = 0
                }
                return
            }

            // move inside storageinfo
            if(storageinfo.currentIndex != -1) {
                storageinfo.currentIndex = Math.max(storageinfo.currentIndex-distance, 1)
                return
            }

        }

    }

    function loadHighlightedItem() {

        if(openvariables.currentFocusOn != "userplaces")
            return

        if(standardlocations.visible && standardlocations.currentIndex != -1) {

            if(standardlocations.model.get(standardlocations.currentIndex) == undefined)
                return

            openvariables.currentDirectory = standardlocations.model.get(standardlocations.currentIndex).location

        } else if(userPlaces.visible && userPlaces.currentIndex != -1) {

            if(userPlaces.model.get(userPlaces.currentIndex) == undefined)
                return

            openvariables.currentDirectory = userPlaces.model.get(userPlaces.currentIndex).path

        } else if(storageinfo.visible && storageinfo.currentIndex != -1) {

            if(storageinfo.model.get(storageinfo.currentIndex) == undefined)
                return

            openvariables.currentDirectory = storageinfo.model.get(storageinfo.currentIndex).location

        }

    }

}
