import QtQuick 2.3
import "../elements"

Rectangle {

    id: ele_top

    color: "#88000000"
    anchors.fill: parent

    opacity: 0
    visible: opacity!=0
    Behavior on opacity { NumberAnimation { duration: 300; } }

    // click on bg closes element
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked:
            hide()
        onWheel: { }
    }

    // item containing text in middle
    Rectangle {
        id: cont
        color: "#bb000000"
        width: 600
        height: flick.height+40
        radius: 5
        border.width: 1
        border.color: "#99999999"
        x: (parent.width-width)/2
        y: (parent.height-height)/2

        // don't close when clicking on text
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        ScrollBarVertical {
            flickable: flick
        }

        // since we have a max height, we use a flickable to accommodate longer text
        Flickable {

            id: flick

            x: 20
            y: 20
            width: parent.width-40
            height: Math.min(flickcont.height,500)
            contentHeight: flickcont.height
            clip: true


            // the content item
            Rectangle {

                id: flickcont

                color: "transparent"
                width: flick.width
                height: childrenRect.height

                // a colum for two text items: settings title and settings helptext
                Column {

                    spacing: 20

                    // the settings title
                    Text {
                        id: setting_title
                        width: flick.width
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 30
                        wrapMode: Text.WordWrap
                        font.bold: true
                        color: "white"
                        text: "Settings Title"
                    }
                    // the settings helptext
                    Text {
                        id: setting_helptext
                        width: flick.width
                        font.pointSize: 15
                        wrapMode: Text.WordWrap
                        color: "white"
                        text: "Some helptext for this setting"

                    }

                }

            }

        }

    }

    // An transparent 'x' also for closing item
    Text {
        x: cont.x+cont.width-width/2
        y: cont.y-height/2
        font.pointSize: 20
        font.bold: true
        opacity: 0.1
        Behavior on opacity { NumberAnimation { duration: 200; } }
        color: "white"
        text: "x"
        ToolTip {
            text: "Click to close"
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.opacity = 0.6
            onExited: parent.opacity = 0.1
            onClicked: hide()
        }
    }

    function show(title, helptext) {
        setting_title.text = title
        setting_helptext.text = helptext
        opacity = 1
    }
    function hide() {
        opacity = 0
    }

}
