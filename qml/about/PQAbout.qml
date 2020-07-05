import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFile

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
        sourceItem: PQSettings.aboutPopoutElement ? dummyitem : imageitem
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
        }

        Text {
            id: heading
            x: 0
            y: 25
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: em.pty+qsTranslate("about", "About PhotoQt")
            font.pointSize: 25
            font.bold: true
            color: "white"
        }

        Rectangle {
            id: sep_top
            color: "white"
            x: 0
            y: heading.y+heading.height+25
            width: parent.width
            height: 1
        }

        Flickable {
            id: flickable
            anchors {
                top: sep_top.bottom
                bottom: sep_bot.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            clip: true
            contentHeight: col.height

            Column {

                id: col

                // Main text
                Text {
                    id: txt
                    width: flickable.width
                    color: "white"
                    font.pointSize: 15
                    wrapMode: Text.WordWrap
                    textFormat:Text.RichText
                    lineHeight: 1.1
                    text: {
                        "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
                        + em.pty+qsTranslate("about", "PhotoQt is a simple image viewer, designed to be good looking, highly configurable, yet easy to use and fast.")
                        + "<br><br>"
                        + "<b>" + em.pty+qsTranslate("about", "Another image viewer?") + "</b><br>"
                        + em.pty+qsTranslate("about", "There are many good image viewers out there. But PhotoQt is a little different than all of them. Its interface is\
         kept very simple, yet there is an abundance of settings to turn PhotoQt from AN image viewer into YOUR image viewer.") + " "
                        + em.pty+qsTranslate("about", "Occasionally someone comes along because they think PhotoQt is 'like Picasa'. However, if you take a good look at it\
         then you see that they are in fact quite different. I myself have never used Picasa, and don't have any intention to copy Picasa. With PhotoQt I\
         want to do my own thing, and to do that as good as I can.")
                        + "<br><br>"
                        +"<b>" + em.pty+qsTranslate("about", "So then, who are you?") + "</b><br>"
                        + em.pty+qsTranslate("about", "I am Lukas Spies, the sole developer of PhotoQt. Born and raised in the southwest of Germany, I left my home country\
         for university shortly after finishing school. Since then I have live for some years in Ireland, Canada, USA, and France, studying and doing\
         research in Mathematics and Scientific Computing. I started playing around with programming since I was about 15 years old. So most of my\
         programming knowledge is self-taught through books and websites. The past few years of my studies I also did a lot of programming as part of my\
         research. Through all of that I gained a good bit of experience in programming using different programming languages. This becomes especially\
         apparent when looking at how PhotoQt has changed since it started at the end of 2011.")
                        + "<br><br><br>"
                        + em.pty+qsTranslate("about", "Don't forget to check out the website:")
                        + " <a href=\"http://photoqt.org\">http://PhotoQt.org</a>. "
                        + em.pty+qsTranslate("about", "If you find a bug or if you have a question or suggestion, please tell me. I'm open to any feedback I get!")
                        + "<br>";

                    }
                    // Pointing hand cursor and click when over link
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: txt.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if(txt.hoveredLink)
                                Qt.openUrlExternally(txt.hoveredLink)
                        }
                    }
                }

                // Big text thanking supporters and contributors
                Rectangle {

                    width: flickable.width
                    height: childrenRect.height
                    color: "#00000000"

                    Text {
                        x: (parent.width-width)/2
                        width: (flickable.width)/2

                        horizontalAlignment: Qt.AlignHCenter
                        color: "white"

                        font.pointSize: 20
                        font.bold: true

                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        lineHeight: 1.1

                        text: em.pty+qsTranslate("about", "Thanks to everybody who contributed to PhotoQt and/or translated PhotoQt to another language! You guys rock!")
                    }
                }

                // Finish up, invitation to join the team
                Text {

                    width: flickable.width

                    color: "white"

                    font.pointSize: 15
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    lineHeight: 1.1

                    text: "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>" +
                          //: Don't forget to add the %1 in your translation, it is a placeholder for the email address!!
                          em.pty+qsTranslate("about", "You want to join the team and do something, e.g. translating PhotoQt to another language? Drop me and email (%1),\
                          and for translations, check the project page on Transifex:").arg("<a href=\"mailto:Lukas@photoqt.org\">Lukas@photoqt.org</a>") +
                          " <a href=\"http://transifex.com/projects/p/photo\">http://transifex.com/projects/p/photo</a>. " +
                          em.pty+qsTranslate("about", "If you want to support PhotoQt with a donation, you can do so via PayPal here:") +
                          " <a href=\"http://photoqt.org/donate\">http://photoqt.org/donate</a>."

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if(parent.hoveredLink)
                                Qt.openUrlExternally(parent.hoveredLink)
                        }
                    }
                }

            }

        }

        Rectangle {
            id: sep_bot
            color: "white"
            x: 0
            y: button_close.y-10
            width: parent.width
            height: 1
        }

        PQButton {
            id: button_close
            x: (parent.width-width)/2
            y: parent.height-height-10
            text: em.pty+qsTranslate("about", "Go back to PhotoQt")
            onClicked: {
                about_top.opacity = 0
                variables.visibleItem = ""
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
