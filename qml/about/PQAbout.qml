import QtQuick 2.9
import QtGraphicalEffects 1.0

import "../elements"

Item {

    id: about_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.fileDeletePopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: em.pty+qsTranslate("about", "Close")
            enabled: !PQSettings.aboutPopoutElement
            onClicked:
                button_close.clicked()
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: childrenRect.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 10

                Item {
                    width: 1
                    height: 5
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 25
                    font.bold: true
                    text: "   PhotoQt v" + handlingGeneral.getVersion() + "   "
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 15
                    property date currentDate: new Date()
                    text: "&copy; 2011-" + Qt.formatDateTime(new Date(), "yyyy") + " Lukas Spies"
                    textFormat: Text.RichText
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "License:") + " GPL 2+"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Open license")
                        onClicked:
                            Qt.openUrlExternally("http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt")
                    }
                }

                Item {
                    width: 1
                    height: 1
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "Website:") + " https://photoqt.org"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Open website")
                        onClicked:
                            Qt.openUrlExternally("https://photoqt.org")
                    }
                }

                Text {
                    x: (parent.width-width)/2
                    color: "white"
                    font.pointSize: 12
                    text: em.pty+qsTranslate("about", "Contact:") + " Lukas@photoqt.org"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: em.pty+qsTranslate("about", "Send an email")
                        onClicked:
                            Qt.openUrlExternally("mailto:Lukas@photoqt.org")
                    }
                }

                Item {
                    width: 1
                    height: 5
                }

                PQButton {
                    id: button_close
                    x: (parent.width-width)/2
                    y: parent.height-height-10
                    text: em.pty+qsTranslate("about", "Close")
                    tooltip: text
                    onClicked: {
                        about_top.opacity = 0
                        variables.visibleItem = ""
                    }
                }

                Item {
                    width: 1
                    height: 5
                }

            }

        }

        Connections {
            target: loader
            onAboutPassOn: {
                if(what == "show") {
                    opacity = 1
                    variables.visibleItem = "about"
                } else if(what == "hide") {
                    button_close.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_close.clicked()
                }
            }
        }



        Shortcut {
            sequence: "Esc"
            enabled: PQSettings.aboutPopoutElement
            onActivated: button_close.clicked()
        }

    }

}
