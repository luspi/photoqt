import QtQuick 2.3

Rectangle {

    id: confirm

    property int confirmWidth: 500
    property int confirmHeight: 300
    property Item fillAnchors: parent

    property string header: "Confirm me?"
    property string description: "Do you really want to do this?"
    property string confirmbuttontext: "Yes, do it"
    property string rejectbuttontext: "No, don't"

    signal accepted()
    signal rejected()

    anchors.fill: fillAnchors

    opacity: 0
    visible: false

    color: colour_fadein_block_bg

    // Click on background is like rejecting it
    // (this MouseArea has to come here at the top so that it can be overwritten below for the actual widget
    // (no click on actual rect should close it))
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if(!rect.contains(Qt.point(mouse.x,mouse.y)))
                hideConfirm.start()
        }
    }

    Rectangle {

        id: rect

        // position it
        x: (parent.width-width)/2
        y: (parent.height-height)/2

        // Set size
        width: confirmWidth
        height: confirmHeight

        // Adjust colour and look
        color: colour_fadein_bg
        border.width: 1
        border.color: colour_fadein_border
        radius: 5

        // Confirmation text
        Text {

            anchors.fill: parent
            anchors.margins: 5
            anchors.bottomMargin: butrect.height

            color: "white"
            font.pointSize: 13
            wrapMode: Text.WordWrap

            text: "<h1>" + header + "</h1><br>" + description

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

        }

        // Mousearea preventing background mousearea from catching clicks
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {}
        }

        // Buttons for accepting/rejecting
        Rectangle {

            id: butrect

            x: 5
            y: parent.height-childrenRect.height-5
            width: parent.width-10
            height: childrenRect.height

            color: "#00000000"

            Row {

                id: butrow
                spacing: 5

                CustomButton {

                    width: (butrect.width-butrow.spacing)/2
                    text: confirmbuttontext

                    onClickedButton: {
                        accepted()
                        hide()
                    }

                }

                CustomButton {

                    width: (butrect.width-butrow.spacing)/2
                    text: rejectbuttontext

                    onClickedButton: {
                        rejected()
                        hide()
                    }

                }
            }
        }

    }

    function show() {
        showConfirm.start()
    }
    function hide() {
        hideConfirm.start()
    }

    PropertyAnimation {
        id: hideConfirm
        target: confirm
        property: "opacity"
        to: 0
        onStopped: {
            visible = false
        }
    }
    PropertyAnimation {
        id: showConfirm
        target: confirm
        property: "opacity"
        to: 1
        onStarted: {
            visible = true
        }
    }

}
