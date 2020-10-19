import QtQuick 2.9

import "../../../elements"

Item {

    id: availtop

    width: shcont.width/2-15
    height: Math.max(view.height+20, nothingset.height)

    property bool thisIsAnExternalCategory: false

    Text {
        id: nothingset
        width: parent.width
        height: 100
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.italic: true
        color: "#666666"
        text: "(" + em.pty+qsTranslate("settingsmanager_shortcuts", "No shortcut set") + ")"
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

                id: cmd_txt
                x: 10
                y: 5
                width: parent.width/2-15
                elide: Text.ElideRight
                visible: !thisIsAnExternalCategory
                color: "#dddddd"
                text: ""
                Component.onCompleted: {
                    if(!thisIsAnExternalCategory) {
                        for(var i = 0; i < shcont.available.length; ++i) {
                            if(shcont.available[i][0] == cmd) {
                                text = shcont.available[i][1]
                                break
                            }
                        }
                    }
                }

            }

            PQCheckbox {

                id: close_chk

                visible: thisIsAnExternalCategory
                x: 5
                y: (parent.height-height)/2
                //: checkbox in shortcuts settings, used as in: quit PhotoQt. Please keep as short as possible!
                text: em.pty+qsTranslate("settingsmanager_shortcuts", "quit")
                checked: close=="1"
                onCheckedChanged:
                    close = (checked ? "1" : "0")
            }

            PQLineEdit {

                visible: thisIsAnExternalCategory

                x: close_chk.width+10
                height: delbut.height+10
                width: parent.width/2-20 - close_chk.width
                text: cmd
                onTextEdited: {
                    cmd = text
                }

            }

            Text {

                id: sh_txt

                property bool newsh: false

                x: parent.width/2
                width: parent.width/2 - delbut.width-20
                elide: Text.ElideRight
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
                anchors.leftMargin: thisIsAnExternalCategory ? parent.width/2 : 0
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                tooltip: cmd_txt.text + "<br><b>" + sh_txt.text + "</b><br><br>" + em.pty+qsTranslate("settingsmanager_shortcuts", "Click to change shortcut.")
                onClicked: {
                    detectingNewShortcut = true
                    detectcombo.show(handlingShortcuts.composeDisplayString(sh))
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
                tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to delete shortcut")
                onClicked:
                    parent.inProcessOfDeletingMe = true
            }

            Component.onCompleted: {
                inProcessOfCreatingMe = false
                if(sh == "") {
                    detectingNewShortcut = true
                    detectcombo.show("")
                }
            }

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
            var dat = {"sh" : shcont.active[i][1], "cmd" : shcont.active[i][2], "close" : shcont.active[i][0], "deleted" : false}
            setmodel.append(dat)
        }

    }

    function addShortcut(cmd) {
        var dat = {"sh" : "", "cmd" : cmd, "close" : "0", "deleted" : false}
        setmodel.append(dat)
    }

    function getActiveShortcuts() {
        var ret = []
        for(var i = 0; i < view.count; ++i) {
            var tmp = [setmodel.get(i).close, setmodel.get(i).sh, setmodel.get(i).cmd]
            ret.push(tmp)
        }
        return ret
    }

}
