import QtQuick 2.4
import QtQuick.Controls 1.3

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
                + qsTr("With PhotoQt I try to be different than other image viewers (after all, there are plenty of good image viewers already out there). Its interface is kept very simple, yet there is an abundance of settings to customize the look and feel to make PhotoQt YOUR image viewer.")
                + "<br><br>"
                + qsTr("I'm not a trained programmer. I'm a simple Maths student that loves doing stuff like this. Most of my programming knowledge I taught myself over the past 10-ish years, and it has been developing a lot since I started PhotoQt. During my studies in university I learned a lot about the basics of programming that I was missing. And simply working on PhotoQt gave me a lot of invaluable experience. So the code of PhotoQt might in places not quite be done in the best of ways, but I think it's getting better and better with each release.")
                + "<br><br>"
                + qsTr("I heard a number of times people saying, that PhotoQt is a 'copy' of Picasa's image viewer. Well, it's not. In fact, I myself have never used Picasa. I have seen it in use though by others, and I can't deny that it influenced the basic design idea a little. But I'm not trying to do something 'like Picasa'. I try to do my own thing, and to do it as good as I can.")
                + "<br><br>"
                + qsTr("Don't forget to check out the website:")
                + " <a href=\"http://photoqt.org\">http://PhotoQt.org</a><br><br>"
                + qsTr("If you find a bug or if you have a question or suggestion, tell me. I'm open to any feedback I get :)")
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

            //: Don't forget to add the %1 in your translation!!
            text: "<style type='text/css'>a:link{color:white; text-decoration: none; font-style: italic; }</style><br>"
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

            text: qsTr("Okay I got enough of that")
            onClickedButton: hideAbout()

        }
    ]

    function showAbout() {
        show()
    }
    function hideAbout() {
        hide()
    }

}
