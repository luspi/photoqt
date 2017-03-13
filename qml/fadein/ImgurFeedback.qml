import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: feedback_top
    anchors.fill: parent
    color: "#88000000"

    visible: opacity!=0
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 300; } }
    onOpacityChanged: {
        if(opacity == 1) {
            blurAllBackgroundElements()
            blocked = true
        } else {
            unblurAllBackgroundElements()
            blocked = false
        }
    }

    property int progress: 0
    property bool anonymous: false
    property string accountname: ""

    // Click on margin outside elements closes element
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: hide()
    }

    Rectangle {

        color: "transparent"
        width: parent.width
        height: childrenRect.height

        y: (parent.height-height)/2

        Column {

            spacing: 20

            Text {
                horizontalAlignment: Text.AlignHCenter
                width: feedback_top.width
                wrapMode: Text.WordWrap
                text: "Uploading image to imgur.com" + (anonymous ? " anonymously" : " account '" + accountname + "'")
                color: "white"
                font.pointSize: 40
                font.bold: true
            }

            Text {
                horizontalAlignment: Text.AlignHCenter
                width: feedback_top.width
                wrapMode: Text.WordWrap
                text: getanddostuff.removePathFromFilename(thumbnailBar.currentFile, false)
                color: "white"
                font.pointSize: 30
                font.italic: true
                font.bold: true
            }

            Rectangle {
                color: "transparent"
                width: 1
                height: 1
            }

            CustomProgressBar {
                id: progressbar
                x: (feedback_top.width-width)/2
            }

            CustomButton {
                x: (parent.width-width)/2
                text: "Cancel upload"
                fontsize: 30
                onClickedButton:
                    hide()
            }

        }

    }

    Connections {
        target: shareonline_imgur
        onImgurUploadProgress: {
            progressbar.setProgress(Math.max(perc*100 -1, 0))
        }
        onFinished: {
            progressbar.setProgress(100)
            hide()
        }
        onImgurImageUrl:
            console.log("Image URL:", url)
        onImgurDeleteHash:
            console.log("Delete hash:", url)

    }

    function show(anonym) {

        anonymous = anonym

        if(!anonymous) {
            var ret = shareonline_imgur.authAccount()
            if(ret !== 0) {
                console.log("Imgur authentication failed!!")
                hide()
                return
            }
            accountname = shareonline_imgur.getAccountUsername()
            shareonline_imgur.upload(thumbnailBar.currentFile)
        } else {
            accountname = ""
            shareonline_imgur.anonymousUpload(thumbnailBar.currentFile)
        }
        opacity = 1

    }


    function hide() {
        shareonline_imgur.abort()
        opacity = 0
    }

}
