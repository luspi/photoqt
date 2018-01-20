import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"
import "../loadfile.js" as Load

Rectangle {

    id: rect

    // Positioning and basic look
    x: 0
    y: 0
    width: mainwindow.width
    height: mainwindow.height
    color: colour.fadein_slidein_bg

    // Invisible at startup
    opacity: 0
    visible: opacity!=0

    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
    property real lastOpacityValue: 0
    onOpacityChanged: {
        if(openFileAfter == "" && opacity > 0.1 && opacity < lastOpacityValue)
            call.show("openfile")
        else if(!visible)
            Load.loadFile(openFileAfter, variables.filter)
        lastOpacityValue = opacity
    }

    property string type: ""

    property string openFileAfter: ""

    // Catch mouse events
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    // Scrollarea
    Rectangle {

        id: holder

        color: "transparent"

        width: rect.width
        height: col.height

        anchors.horizontalCenter: rect.horizontalCenter
        anchors.verticalCenter: rect.verticalCenter

        clip: true

        Column {

            id: col

            spacing: 15

            Rectangle {
                color: "#00000000"
                width: 1
                height: 5
            }

            // HEADER LOGO
            Image {
                source: "qrc:/img/logo.png"
                width: Math.min(300, holder.width/2)
                height: sourceSize.height*(width/sourceSize.width)
                x: (holder.width-width)/2
            }

            Rectangle {
                color: "#00000000"
                width: 1
                height: 10
            }

            Text {
                id: welcome
                text: em.pty+qsTr("Welcome to PhotoQt")
                color: "white"
                font.pointSize: 45
                width: holder.width
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                color: "white"
                font.pointSize: 20
                width: Math.min(welcome.width-200,600)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: type=="installed" ? em.pty+qsTr("PhotoQt was successfully installed!") + "<br>"
                                          + em.pty+qsTr("An image viewer packed with features and adjustable in every detail awaits you... Go, enjoy :-)")
                                        : em.pty+qsTr("PhotoQt was successfully updated!") + "<br>"
                                          + em.pty+qsTr("Many new features and bug fixes await you... Go, enjoy :-)")
            }

            Rectangle {
                color: "#00000000"
                width: 1
                height: 15
            }

            CustomButton {
                text: em.pty+qsTr("Lets get started!")
                fontsize: 30
                anchors.horizontalCenter: col.horizontalCenter
                onClickedButton: hideStartup()
            }

        } // END Column

    } // END Flickable

    Connections {
        target: call
        onStartupShow:
            showStartup(type, filename)
        onShortcut: {
            if(!rect.visible) return
            if(sh == "Escape")
                hideStartup()
        }
        onCloseAnyElement:
            if(rect.visible)
                hideStartup()
    }

    function showStartup(t, filenameAfter) {

        type = (t==1 ? "updated" : "installed");
        openFileAfter = filenameAfter

        opacity = 1
        variables.guiBlocked = true

    }

    function hideStartup() {

        opacity = 0
        variables.guiBlocked = false

    }

}
