import QtQuick

Rectangle {

    id: modal_top

    anchors.fill: parent
    color: PQCLook.transColor

    property string action: ""
    property var payload: []

    property alias button1: acceptButton
    property alias button2: rejectButton

    signal accepted()
    signal rejected()

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            mouse.accepted = true
        }
    }

    Rectangle {

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: col.width+100
        height: col.height+100

        color: PQCLook.baseColor

        border.width: 2
        border.color: PQCLook.baseColorHighlight

        radius: 5

        Column {

            id: col

            x: 50
            y: 50

            spacing: 20

            PQTextXXL {
                id: header
                text: "Are you sure?"
                width: Math.min(modal_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
                font.weight: PQCLook.fontWeightBold
            }

            PQTextL {
                id: description
                text: "Are you sure you want to do this???"
                width: Math.min(modal_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
            }

            Row {

                x: (header.width-width)/2

                spacing: 10

                PQButton {
                    id: acceptButton
                    text: "Yes"
                    onClicked: {
                        hide()
                        modal_top.accepted()
                    }
                }

                PQButton {
                    id: rejectButton
                    text: "No"
                    onClicked: {
                        hide()
                        modal_top.rejected()
                    }
                }

            }

        }

    }

    function show(headertext, desctext, action, payload) {
        modal_top.action = action
        modal_top.payload = payload
        header.text = headertext
        description.text = desctext
        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
