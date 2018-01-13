import QtQuick 2.5
import QtQuick.Controls 1.4

import "../elements"

FadeInTemplate {

    id: about

    heading: qsTr("About PhotoQt") + " v" + getanddostuff.getVersionString()

    content: [

        Rectangle {
            color: "transparent"
            width: 1
            height: 5
        },

        Image {
            source: "qrc:/img/logo.png"
            sourceSize.width: 400
            x: (parent.width-width)/2
        },

        // Main text
        Text {
            id: txt
            width: about.contentWidth
            color: colour.text
            font.pointSize: 12
            wrapMode: Text.WordWrap
            textFormat:Text.RichText
            text: {
                "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
                + qsTr("PhotoQt is a simple image viewer, designed to be good looking, highly configurable, yet easy to use and fast.")
                + "<br><br>"
                + "<b>" + qsTr("Another image viewer?") + "</b><br>"
                + qsTr("There are many good image viewers out there. But PhotoQt is a little different than all of them. Its interface is kept very simple, yet there is an abundance of settings to turn PhotoQt from AN image viewer into YOUR image viewer.")
                + "<br><br>"
                + qsTr("Occasionally someone comes along because they think PhotoQt is 'like Picasa'. However, if you take a good look at it then you see that they are in fact quite different. I myself have never used Picasa, and don't have any intention to copy Picasa. With PhotoQt I want to do my own thing, and to do that as good as I can.")
                + "<br><br>"
                +"<b>" + qsTr("So then, who are you?") + "</b><br>"
                + qsTr("I started playing around with programming since I was about 15 years old. So most of my programming knowledge is self-taught through books and websites. The past few years I also did a lot of programming as part of my studies and research (I did a Bachelors in Mathematics, and a Masters in Scientific Computing, followed by research in that field). Through all of that I gained a good bit of experience in programming using different programming languages. This becomes especially apparent when looking at how PhotoQt has changed since it started at the end of 2011.")
                + "<br><br><br>"
                + qsTr("Don't forget to check out the website:")
                + " <a href=\"http://photoqt.org\">http://PhotoQt.org</a>. "
                + qsTr("If you find a bug or if you have a question or suggestion, please tell me. I'm open to any feedback I get!")
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
        },

        // Big text thanking supporters and contributors
        Rectangle {

            width: about.contentWidth
            height: childrenRect.height
            color: "#00000000"

            Text {
                x: (parent.width-width)/2
                width: (about.contentWidth)/2

                horizontalAlignment: Qt.AlignHCenter
                color: colour.text

                font.pointSize: 18
                font.bold: true

                wrapMode: Text.WordWrap
                textFormat: Text.RichText

                text: qsTr("Thanks to everybody who contributed to PhotoQt and/or translated PhotoQt to another language! You guys rock!")
            }
        },

        // Finish up, invitation to join the team
        Text {

            width: about.contentWidth

            color: colour.text

            font.pointSize: 12
            wrapMode: Text.WordWrap
            textFormat: Text.RichText

            text: "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
                  //: Don't forget to add the %1 in your translation, it is a placeholder for the email address!!
                + qsTr("You want to join the team and do something, e.g. translating PhotoQt to another language? Drop me and email (%1), and for translations, check the project page on Transifex:").arg("<a href=\"mailto:Lukas@photoqt.org\">Lukas@photoqt.org</a>") + " <a href=\"http://transifex.com/projects/p/photo\">http://transifex.com/projects/p/photo</a>."

            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if(parent.hoveredLink)
                        Qt.openUrlExternally(parent.hoveredLink)
                }
            }
        }
    ]

    buttons: [
        CustomButton {

            id: but

            // The button is in the middle of the space between line above and end of rectangle below
            x: (parent.width-width)/2
            y: 5
            height: 30

            // About element, written on button to close it
            text: qsTr("Okay, take me back")
            onClickedButton: hide()

        }
    ]

    Connections {
        target: call
        onAboutShow:
            show()
        onShortcut: {
            if(!about.visible) return
            if(sh == "Escape")
                hide()
        }
    }

}
