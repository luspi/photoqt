import QtQuick 2.9

import "../../../elements"

Rectangle {

    id: shcont

    color: "#333333"
    radius: 10

    width: cont.width-25
    height: col.height+20

    property alias category: cat.text
    property alias subtitle: subcat.text
    property var available: ({})
    property bool thisIsAnExternalCategory: false

    property var active: []

    signal newShortcutCombo(var combo)

    Column {

        id: col

        x: 10
        y: 10

        Text {
            id: cat
            color: "white"
            text: "Category"
            font.bold: true
            font.pointSize: 12
            x: (parent.width-width)/2
        }

        Item {
            width: 1
            height: 5
        }

        Text {
            id: subcat
            color: "#aaaaaa"
            font.pointSize: 10
            x: (parent.width-width)/2
            visible: text != ""
        }

        Item {
            width: 1
            height: 5
        }

        Row {
            width: shcont.width
            Text {
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                text: "Active shortcuts"
            }
            Text {
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                text: "Available commands"
            }
        }

        Item {
            width: 1
            height: 5
        }

        Row {

            spacing: 10

            PQActiveShortcuts { id: act; thisIsAnExternalCategory: shcont.thisIsAnExternalCategory }
            PQAvailableCommands { id: ava; thisIsAnExternalCategory: shcont.thisIsAnExternalCategory }

        }

        PQDetectCombo {
            id: detectcombo
            onVisibleChanged: {
                if(!visible)
                    newShortcutCombo(currentcombo)
             }
        }

    }

    function loadTiles() {
        act.loadTiles()
    }
    function addShortcut(cmd) {
        act.addShortcut(cmd)
    }
    function getActiveShortcuts() {
        return act.getActiveShortcuts()
    }

}
