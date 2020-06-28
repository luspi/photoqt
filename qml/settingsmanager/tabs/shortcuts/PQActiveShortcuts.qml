import QtQuick 2.9

import "../../../elements"

Item {

    id: availtop

    width: shcont.width/2-15
    height: view.height+20

    Text {
        width: parent.width
        height: 100
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.italic: true
        color: "#666666"
        text: "(No shortcut set)"
        visible: view.count==0
    }

    ListView {

        id: view

        x: 10
        y: 10

        spacing: 5
        interactive: false

        width: parent.width
        height: childrenRect.height

        model: ListModel { id: setmodel }

        delegate: Rectangle {

            radius: 5
            clip: true

            width: availtop.width-20
            height: (inProcessOfDeletingMe || inProcessOfCreatingMe) ? 0 : delbut.height+10
            Behavior on height { NumberAnimation { duration: 150 } }
            onHeightChanged: {
                if(height == 0 && inProcessOfDeletingMe) {
                    deleted = true
                    view.deleteElementsWithHeightZero()
                }
            }

            color: delhovered ? "#44ff0000" : (sh_txt.text=="..." ? "#440000aa" : (hovered ? "#2a2a2a" : "#222222"))
            Behavior on color { ColorAnimation { duration: 100 } }

            property bool inProcessOfCreatingMe: true
            property bool inProcessOfDeletingMe: false

            property bool hovered: false
            property bool delhovered: false

            property bool detectingNewShortcut: false

            Text {

                x: 10
                y: 5
                color: "#dddddd"
                text: ""
                Component.onCompleted: {
                    for(var i = 0; i < shcont.available.length; ++i) {
                        if(shcont.available[i][0] == cmd) {
                            text = shcont.available[i][1]
                            break
                        }
                    }
                }

            }

            Text {

                id: sh_txt

                property bool newsh: false

                x: parent.width/2
                y: 5
                font.bold: true
                color: newsh ? "#00ff00" : "#dddddd"
                Behavior on color { ColorAnimation { id: sh_txt_colani; duration: 1000 } }
                text: handlingShortcuts.composeDisplayString(sh)

            }

            Text {
                id: delbut
                x: parent.width-width-10
                y: 5
                color: "red"
                text: "x"
                font.bold: true
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                tooltip: "Click to change key combincation"
                onClicked: {
                    detectingNewShortcut = true
                    detectcombo.show()
                }
            }

            PQMouseArea {
                x: parent.width-width
                y: 0
                width: delbut.width+20
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.delhovered = true
                onExited: parent.delhovered = false
                tooltip: "Click to delete shortcut"
                onClicked:
                    parent.inProcessOfDeletingMe = true
            }

            Component.onCompleted:
                inProcessOfCreatingMe = false

            Connections {
                target: shcont
                onNewShortcutCombo: {
                    if(detectingNewShortcut && combo != "") {
                        sh = combo
                        sh_txt_colani.duration = 0
                        sh_txt.newsh = true
                        sh_txt_colani.duration  = 2000
                        sh_txt.newsh = false
                    }
                    detectingNewShortcut = false
                }
            }

        }

        function deleteElementsWithHeightZero() {
            for(var i = 0; i < view.count; ++i) {
                if(setmodel.get(i).deleted)
                    setmodel.remove(i)
            }
        }

    }

    function loadTiles() {

        setmodel.clear()

        for(var i = 0; i < shcont.active.length; ++i) {
            var dat = {"sh" : shcont.active[i][1], "cmd" : shcont.active[i][2], "deleted" : false}
            setmodel.append(dat)
        }

    }

    function addShortcut(cmd) {
        var dat = {"sh" : "...", "cmd" : cmd, "deleted" : false}
        setmodel.append(dat)
    }

}
