import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import ToolTip 1.0

import "../../../elements"

Rectangle {

    id: top

    // The height adjusts dynamically depending on how many elements there are
    height: Math.max(childrenRect.height,5)
    Behavior on height { NumberAnimation { duration: 150; } }

    // An external shortcut shows a TextEdit instead of a title
    property bool external: parent.parent.external

    property string lastaction : ""

    // This signal is emitted with the currently deleted item index (actually, its position in the list)
    // This is needed, since when an item with a lower index has been deleted, then we need to adjust
    // the positions of the following items
    signal itemDeleted(var itemIndex)

    color: "transparent"
    radius: 4
    clip: true

    GridView {

        id: grid

        x: 3
        y: 3
        width: parent.width-6
        height: count*cellHeight

        cellWidth: parent.width
        cellHeight: 30

        model: ListModel { id: gridmodel }

        delegate: Rectangle {

            id: ele

            x: 3
            y: 3
            width: grid.cellWidth-6
            height: grid.cellHeight-6

            radius: 3
            clip: true

            // Change color when hovered
            property bool hovered: false
            color: hovered ? colour.tiles_inactive : colour.tiles_disabled
            Behavior on color { ColorAnimation { duration: 150; } }

            property bool error_doubleShortcut: false

            property int posInList: index

            property bool amDetectingNewShortcut: false

            // Click on title triggers shortcut detection
            ToolTip {
                cursorShape: Qt.PointingHandCursor
                text: qsTr("Click to change shortcut")
                // When a rectangle is clicked, then the lastaction is not anymore 'del' or 'add'
                onClicked: { lastaction = ""; triggerDetection() }
                onEntered: ele.hovered = true
                onExited: ele.hovered = false
            }

            Row {

                x: 4
                y: 2

                Rectangle {
                    id: closeitem
                    color: "transparent"
                    width: childrenRect.width
                    height: ele.height-4
                    property bool checked: false
                    onCheckedChanged:
                        gridmodel.set(ele.posInList,{"close" : checked ? "1" : "0"})
                    visible: external
                    Text{
                        id: theclose
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        //: Shortcuts: KEEP THIS STRING SHORT! It is displayed for external shortcuts as an option to quit PhotoQt after executing shortcut
                        text: qsTr("quit") + "  "
                        color: parent.checked ? "white" : "grey"
                    }
                    ToolTip {
                        cursorShape: Qt.PointingHandCursor
                        text: parent.checked ? qsTr("Quit PhotoQt when executing shortcut") : qsTr("Keep PhotoQt running when executing shortcut")
                        onClicked: parent.checked = !parent.checked
                    }
                }

                // What shortcut this is
                Rectangle {
                    height: ele.height-4
                    width: ele.width/2-6-(closeitem.visible ? closeitem.width : 0)-4
                    color: "transparent"
                    Text {
                        id: thetitle
                        anchors.fill: parent
                        visible: !external
                        color: colour.tiles_text_active
                        elide: Text.ElideRight
                        text: desc
                    }
                    CustomLineEdit {
                        id: externalCommand
                        anchors.fill: parent
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
                                gridmodel.set(ele.posInList,{"cmd" : externalCommand.getText()})
                        }
                    }
                }

                // The currently set key (split into two parts)
                Rectangle {

                    width: (ele.width/2-sh_delete.width)-4
                    height: ele.height-4

                    color: "transparent"

                    Text {
                        color: ele.error_doubleShortcut ? colour.shortcut_double_error : colour.tiles_text_active
                        font.bold: ele.error_doubleShortcut
                        text: "<b>" +
                                (type === "key" ? qsTr("Key") + "</b>: " + str_keys.translateKeyCombo(sh) :
                                                  (type === "mouse" ? qsTr("Mouse") + "</b>: " + str_mouse.translateMouseCombo(sh) :
                                                                      qsTr("Touch") + "</b>: " + sh))
                    }




                }

                Text {
                    id: sh_delete
                    height: ele.height-4
                    color: colour.tiles_text_active
                    Behavior on color { ColorAnimation { duration: 150; } }
                    elide: Text.ElideRight
                    text: "x"
                    horizontalAlignment: Text.AlignHCenter
                    width: 20
                    ToolTip {
                        cursorShape: Qt.PointingHandCursor
                        text: qsTr("Delete shortcut")
                        onClicked: deleteElement.start()
                        onEntered: parent.color = colour.shortcut_double_error
                        onExited: parent.color = colour.tiles_text_active
                    }
                }

            }

            Connections {

                target: grid.parent

                onItemDeleted: {
                    if(itemIndex < ele.posInList)
                        ele.posInList -= 1
                }

            }

            PropertyAnimation {
                id: deleteElement
                target: ele
                property: "x"
                to: -1.1*ele.width
                duration: 200
                onStopped: deleteShortcut(ele.posInList, internalShortcut)
            }

            function triggerDetection() {
                amDetectingNewShortcut = true
                detectshortcut.show()
            }

            Component.onCompleted: {
                if(index == gridmodel.count-1 && lastaction == "add")
                    triggerDetection()
                else {
                    if(type == "touch") {
                        var fingers = sh.split(" fingers")[0];
                        var action = sh.split(" fingers, ")[1].split(": ")[0];
                        var path = sh.split(": ")[1];
                        internalShortcut = fingers + "::" + action + "::" + path
                    } else
                        internalShortcut = sh;
                }
                closeitem.checked = (close == "1")
                detectshortcut.takenShortcutsUpdated()
            }

            Connections {
                target: detectshortcut
                onSuccess: {
                    if(ele.amDetectingNewShortcut) {
                        type = cat
                        var oldone = internalShortcut
                        if(type == "mouse") {
                            sh = (args[0] == "" ? "" : args[0]+"+") + args[1] + (args[2].length == 0 ? "" : "+" + args[2].join(""))
                            internalShortcut = sh
                        } else if(type == "touch") {
                            sh = args[0] + " fingers, " + args[1] + ": " + args[2].join("")
                            internalShortcut = args[0] + "::" + args[1] + "::" + args[2].join("")
                        } else if(type == "key") {
                            sh = args[0]
                            internalShortcut = sh
                        }
                        detectshortcut.updateTakenShortcut(oldone, internalShortcut)
                    }

                    ele.amDetectingNewShortcut = false
                }
                onCancel: {
                    if(lastaction == "add" && ele.amDetectingNewShortcut)
                        deleteShortcut(index, internalShortcut)
                    ele.amDetectingNewShortcut = false
                }
                onTakenShortcutsUpdated: {
                    error_doubleShortcut = detectshortcut.checkIfShortcutTaken(internalShortcut)
                }

            }

        }

    }

    function deleteShortcut(index, sh) {
        detectshortcut.updateTakenShortcut(sh, "")
        gridmodel.remove(index)
        itemDeleted(index)
        lastaction = "del"
    }

    function addShortcut(l) {

        lastaction = "add"

        var c = grid.count
        gridmodel.append({"index" : c, "desc" : l[1], "sh" : "...", "close" : "0", "cmd" : l[0], "type" : "", "internalShortcut" : "" })
    }

    function setData(d) {

        gridmodel.clear()

        var i = 0

        for(var sh in d) {
            gridmodel.append({"index" : i, "desc" : d[i][0], "sh" : d[i][1], "close" : d[i][2]+"", "cmd" : d[i][3], "type" : d[i][4], "internalShortcut" : "" });
            ++i
        }

    }

    function getAllData() {

        var ret = {};
        for(var i = 0; i < gridmodel.count; ++i) {
            var item = gridmodel.get(i)
            ret[item.internalShortcut] = [item.close, item.cmd, item.type]
        }

        return ret;

    }

}
