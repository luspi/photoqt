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

            radius: 3
            clip: true

            // Change color when hovered
            property bool hovered: false
            color: hovered ? colour.tiles_inactive : colour.tiles_disabled
            Behavior on color { ColorAnimation { duration: 150; } }

            // quit or not (only visible for external shortcuts)
            Item {

                id: closeitem

                anchors {
                    left: parent.left
                    leftMargin: 3
                    top: parent.top
                    topMargin: 2
                    bottom: parent.bottom
                    bottomMargin: 2
                }
                width: visible ? childrenRect.width : 0

                property bool checked: false
                onCheckedChanged:
                    listview.model.set(index, {"shClose" : checked ? "1" : "0"})

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

                Text {
                    id: thetitle
                    anchors.fill: parent
                    anchors.rightMargin: parent.width/2
                    visible: !external
                    color: colour.tiles_text_active
                    elide: Text.ElideRight
                    text: shDesc
                }
                CustomLineEdit {
                    id: externalCommand
                    anchors.fill: parent
                    visible: external
                    text: shDesc
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
                            gridmodel.set(index, {"shCmd" : externalCommand.getText()})
                    }
                }

                Text {
                    id: thekey
                    anchors.fill: parent
                    anchors.leftMargin: parent.width/2
                    color: colour.tiles_text_active
                    elide: Text.ElideRight
                    text: strings.translateShortcut(shKey)
                }

                MouseArea {

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: ele.hovered = true
                    onExited: ele.hovered = false

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
                }

            }

        }

    }

    function setData(sh) {

        listview.model.clear()

        for(var i = 0; i < sh.length; ++i)
            listview.model.append({"shDesc" : sh[i][0], "shKey" : sh[i][1], "shClose" : sh[i][2], "shCmd" : sh[i][3]})

    }

}
