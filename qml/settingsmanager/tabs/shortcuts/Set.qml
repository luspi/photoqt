import QtQuick 2.6

import "../../../elements"

Item {

    id: setTop

    height: Math.max(childrenRect.height,5)
    Behavior on height { NumberAnimation { duration: 150; } }

    property bool external: shortcutscontainer.external

    clip: true

    ListView {

        id: listview

        x: 3
        y: 3
        width: parent.width-6
        height: count*(elementHeight+spacing)

        spacing: 6

        interactive: false

        property int elementHeight: 24

        model: ListModel { }

        delegate: Rectangle {

            id: ele

            width: listview.width-6
            height: listview.elementHeight
            Behavior on height { NumberAnimation { duration: 50 } }

            radius: 3
            clip: true

            Behavior on x { NumberAnimation { duration: 300 } }
            onXChanged: {
                if(x <= -ele.width)
                    listview.model.remove(index)
            }

            // Change color when hovered
            property bool hovered: false
            color: hovered ? colour.tiles_inactive : colour.tiles_disabled
            Behavior on color { ColorAnimation { duration: 150; } }

            property bool hotForShortcutDetection: false

            // quit or not (only visible for external shortcuts)
            Item {

                id: closeitem

                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    topMargin: 2
                    bottom: parent.bottom
                    bottomMargin: 2
                }
                width: visible ? childrenRect.width : 0

                property bool checked: false
                onCheckedChanged:
                    listview.model.set(index, {"close" : checked ? "1" : "0"})

                visible: external

                Text{

                    id: theclose

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    color: closeitem.checked ? "white" : "grey"

                    //: Shortcuts: KEEP THIS STRING SHORT! It is displayed for external shortcuts as an option to quit PhotoQt after executing shortcut
                    text: qsTr("quit") + "  "

                    ToolTip {

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        text: closeitem.checked ? qsTr("Quit PhotoQt when executing shortcut") : qsTr("Keep PhotoQt running when executing shortcut")
                        onClicked: closeitem.checked = !closeitem.checked

                    }
                }

            }

            // What shortcut this is
            Item {

                anchors {
                    left: closeitem.right
                    leftMargin: 3
                    top: parent.top
                    topMargin: 2
                    bottom: parent.bottom
                    bottomMargin: 2
                    right: deleteItem.left
                    rightMargin: 3
                }

                MouseArea {

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: ele.hovered = true
                    onExited: ele.hovered = false
                    onClicked: {
                        hotForShortcutDetection = true
                        detectshortcut.show()
                    }

                }

                Text {
                    id: thetitle
                    anchors.fill: parent
                    anchors.rightMargin: parent.width/2
                    visible: !external
                    color: colour.tiles_text_active
                    elide: Text.ElideRight
                    text: desc
                }
                CustomLineEdit {
                    id: externalCommand
                    anchors.fill: parent
                    anchors.rightMargin: parent.width/2+closeitem.width
                    visible: external
                    text: desc
                    //: Shortcuts: This is the command to be executed (external shortcut)
                    emptyMessage: qsTr("The command goes here")
                    onTextEdited:
                        updateExternalString.restart()
                }
                Timer {
                    id: updateExternalString
                    interval: 250
                    running: false
                    repeat: false
                    onTriggered: {
                        if(external)
                            listview.model.set(index, {"cmd" : externalCommand.getText()})
                    }
                }

                Text {
                    id: thekey
                    anchors.fill: parent
                    anchors.leftMargin: parent.width/2-closeitem.width/2
                    color: colour.tiles_text_active
                    elide: Text.ElideRight
                    text: strings.translateShortcut(key)
                    Component.onCompleted: {
                        if(text == "...") {
                            ele.hotForShortcutDetection = true
                            detectshortcut.show()
                        }
                    }
                }

            }

            Image {

                id: deleteItem

                property bool hovered: false

                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: 3
                }
                width: ele.height-6

                opacity: hovered ? 1 : 0.3
                Behavior on opacity { NumberAnimation { duration: 200 } }

                source: "qrc:/img/settings/shortcuts/deleteshortcut.png"

                ToolTip {
                    anchors.fill: parent
                    text: qsTr("Delete shortcut")
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        ele.hovered = true
                        deleteItem.hovered = true
                    }
                    onExited: {
                        ele.hovered = false
                        deleteItem.hovered = false
                    }
                    onClicked:
                        ele.deleteThisShortcut()
                }

            }


            Connections {
                target: detectshortcut
                onAbortedShortcutDetection: {
                    if(ele.hotForShortcutDetection) {
                        ele.hotForShortcutDetection = false
                        if(thekey.text == "...")
                            ele.deleteThisShortcut()
                    }
                }
                onGotNewShortcut: {
                    if(ele.hotForShortcutDetection) {
                        ele.hotForShortcutDetection = false
                        thekey.text = sh
                        listview.model.set(index, {"key" : sh})
                    }
                }
            }

            function deleteThisShortcut() {
                ele.x = -ele.width-50
            }

        }

    }

    function setData(sh) {

        listview.model.clear()

        for(var i = 0; i < sh.length; ++i)
            listview.model.append({"desc" : sh[i][0], "key" : sh[i][1], "close" : sh[i][2], "cmd" : sh[i][3]})

    }

    function addShortcut(dat) {

        listview.model.append({"desc" : dat[1], "key" : "...", "close" : "0", "cmd" : dat[0]})

    }

    function saveData() {

        var ret = [[]]

        for(var i = 0; i < listview.model.count; ++i) {
            var item = listview.model.get(i)
            var l = [item.key, item.close, item.cmd]
            ret.push(l)
        }

        return ret

    }

}
