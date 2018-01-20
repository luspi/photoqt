import QtQuick 2.5

Rectangle {

    id: confirm

    property Item fillAnchors: parent

    property int maxwidth: 500

    // these are only placeholder strings, always replaced by custom strings thus no need for translation
    property string header: "Confirm me?"
    property string description: "Do you really want to do this?"
    property string confirmbuttontext: "Yes"
    property string rejectbuttontext: "No"

    property bool alwaysDoThis: false
    property bool showDontAskAgain: false

    property string customisedDontAskAgainMessage: ""
    property bool dontAskAgainChecked: false

    // Only show a 'cancel' option in that case
    property bool actAsErrorMessage: false
    // Only show a 'confirm' option in this case
    property bool actAsInfoMessage: false

    signal accepted()
    signal rejected()

    anchors.fill: fillAnchors

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    visible: opacity!=0

    color: colour.fadein_slidein_block_bg

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
        width: children_container.width+40
        height: children_container.height+40

        // Adjust colour and look
        color: colour.fadein_slidein_bg
        border.width: 1
        border.color: colour.fadein_slidein_border
        radius: variables.global_element_radius

        // Mousearea preventing background mousearea from catching clicks
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {}
        }

        Rectangle {

            id: children_container
            color: "transparent"
            width: maxwidth-20
            height: childrenRect.height
            x: 20
            y: 20

            Column {

                id: col
                spacing: 5

                Text {
                    id: head
                    x: 5
                    width: children_container.width-10
                    color: colour.text
                    font.pointSize: 10
                    wrapMode: Text.WordWrap
                    text: "<h1>" + header + "</h1>"
                    horizontalAlignment: Text.AlignHCenter
                }

                // Confirmation text
                Text {

                    id: txt

                    x: 5
                    width: children_container.width-10

                    color: colour.text
                    font.pointSize: 10
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText

                    text: description

                    horizontalAlignment: Qt.AlignHCenter

                }

                Rectangle {
                    color: "#00000000"
                    width: 1
                    height: 10
                }

                CustomCheckBox {
                    id: ask
                    x: (parent.width-width)/2
                    text: customisedDontAskAgainMessage=="" ? em.pty+qsTr("Don't ask again") : customisedDontAskAgainMessage
                    visible: showDontAskAgain
                    checkedButton: dontAskAgainChecked
                }

                Rectangle {
                    color: "#00000000"
                    width: 1
                    height: 10
                }

                // Buttons for accepting/rejecting
                Rectangle {

                    id: butrect

                    x: 5
                    width: children_container.width-10
                    height: childrenRect.height

                    color: "#00000000"

                    Row {

                        id: butrow
                        spacing: 5

                        // When this CustomConfirm is supposed to act as error message box, then the two rectangles ensure the button is centered
                        // Otherwise they simply remain hidden

                        Rectangle {
                            color: "transparent"
                            width: (butrect.width-butrow.spacing)/4
                            height: 1
                            visible: actAsErrorMessage||actAsInfoMessage
                        }

                        CustomButton {

                            width: (butrect.width-butrow.spacing)/2
                            text: confirmbuttontext

                            visible: !actAsErrorMessage || actAsInfoMessage

                            onClickedButton: {
                                alwaysDoThis = ask.checkedButton
                                accepted()
                                _hide()
                            }

                        }

                        CustomButton {

                            width: (butrect.width-butrow.spacing)/2
                            text: rejectbuttontext

                            visible: !actAsInfoMessage || actAsErrorMessage

                            onClickedButton: {
                                alwaysDoThis = ask.checkedButton
                                rejected()
                                _hide()
                            }

                        }

                        Rectangle {
                            color: "transparent"
                            width: (butrect.width-butrow.spacing)/4
                            height: 1
                            visible: actAsErrorMessage || actAsInfoMessage
                        }

                    }
                }

            } // END Column

        }

    }



    function show() {
        ask.checkedButton = dontAskAgainChecked
        opacity = 1
    }
    function reject() {
        alwaysDoThis = ask.checkedButton
        rejected()
        _hide()
    }
    function accept() {
        alwaysDoThis = ask.checkedButton
        accepted()
        _hide()
    }
    function _hide() {
        opacity = 0
    }

}
