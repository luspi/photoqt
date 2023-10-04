/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9
import QtQuick.Controls 2.2
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: imgur_top

    popout: PQSettings.interfacePopoutFilter
    shortcut: ""
    title: accountname=="" ?
               em.pty+qsTranslate("imgur", "Upload to imgur.com") :
               em.pty+qsTranslate("imgur", "Upload to imgur.com") + ": " + accountname
    showPopinPopout: false

    property string accountname: ""

    button1.text: genericStringCancel

    button1.onClicked: {
        hide()
    }

    property int progresspercentage: 0
    property int errorCode: 0

    property string imageURL: ""
    property string imageDeleteHash: ""

    states: [
        State {
            name: "uploading"
            PropertyChanges {
                target: statusmessage
                opacity: 0
                text: progresspercentage+"%"
            }
            PropertyChanges {
                target: button1
                text: genericStringCancel
            }
        },
        State {
            name: "busy"
            PropertyChanges {
                target: statusmessage
                opacity: 0
            }
            PropertyChanges {
                target: progressbar
                text: "..."
            }
            PropertyChanges {
                target: button1
                text: genericStringCancel
            }
        },
        State {
            name: "longtime"
            PropertyChanges {
                target: statusmessage
                opacity: 1
                text: qsTranslate("imgur", "This seems to take a long time...") + "<br>" +
                      qsTranslate("imgur", "There might be a problem with your internet connection or the imgur.com servers.")
            }
            PropertyChanges {
                target: progressbar
                text: "..."
            }
            PropertyChanges {
                target: button1
                text: genericStringCancel
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: statusmessage
                opacity: 1
                text: qsTranslate("imgur", "An Error occurred while uploading image!") + "<br>" +
                      qsTranslate("imgur", "Error code:") + " " + errorCode
            }
            PropertyChanges {
                target: progressbar
                text: "..."
            }
            PropertyChanges {
                target: working
                animationRunning: false
            }
            PropertyChanges {
                target: button1
                text: genericStringClose
            }
        },
        State {
            name: "nointernet"
            PropertyChanges {
                target: statusmessage
                opacity: 1
                text: qsTranslate("imgur", "You do not seem to be connected to the internet...") + "<br>" +
                      qsTranslate("imgur", "Unable to upload!")
            }
            PropertyChanges {
                target: progressbar
                text: "..."
            }
            PropertyChanges {
                target: working
                animationRunning: false
            }
            PropertyChanges {
                target: button1
                text: genericStringClose
            }
        },
        State {
            name: "result"
            PropertyChanges {
                target: statusmessage
                opacity: 0
            }
            PropertyChanges {
                target: working
                opacity: 0
            }
            PropertyChanges {
                target: resultscol
                opacity: 1
            }
            PropertyChanges {
                target: button1
                text: genericStringClose
            }
        }

    ]

    state: "uploading"

    // The content item only contains the result
    content: [

        Column {

            id: resultscol

            x: (parent.width-width)/2

            opacity: 0

            spacing: 10

            PQTextL {
                text: qsTranslate("imgur", "Access Image")
                font.weight: baselook.boldweight
            }

            Row {

                spacing: 10

                PQTextL {
                    id: result_access
                    text: imgur_top.imageURL
                    PQMouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        tooltip: qsTranslate("imgur", "Click to open in browser")
                        onClicked:
                            Qt.openUrlExternally(parent.text)
                    }
                }

                PQButton {
                    width: result_access.height
                    height: width
                    imageButtonSource: "/mainmenu/copy.svg"
                    onClicked:
                        handlingExternal.copyTextToClipboard(imgur_top.imageURL)
                }

            }

            Item {
                width: 1
                height: 10
            }

            PQTextL {
                text: qsTranslate("imgur", "Delete Image")
                font.weight: baselook.boldweight
            }

            Row {

                spacing: 10

                PQTextL {
                    id: result_delete
                    text: "https://imgur.com/delete/" + imgur_top.imageDeleteHash
                    PQMouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        tooltip: qsTranslate("imgur", "Click to open in browser")
                        onClicked:
                            Qt.openUrlExternally("https://imgur.com/delete/" + imgur_top.imageDeleteHash)
                    }
                }

                PQButton {
                    width: result_delete.height
                    height: width
                    imageButtonSource: "/mainmenu/copy.svg"
                    onClicked:
                        handlingExternal.copyTextToClipboard("https://imgur.com/delete/" + imgur_top.imageDeleteHash)
                }

            }

        }

    ]

    // The busy indicator
    PQWorking {
        id: working

        anchors.bottomMargin: imgur_top.bottomrowHeight
        anchors.topMargin:  imgur_top.toprowHeight

        PQTextL {
            id: progressbar
            anchors.centerIn: parent
            font.weight: baselook.boldweight
            text: progresspercentage + "%"
        }

    }

    // Some status message
    PQText {
        id: statusmessage
        x: (parent.width-width)/2
        y: (parent.height-height)/2 + working.circleHeight*0.8
        horizontalAlignment: Text.AlignHCenter
        font.weight: baselook.boldweight
    }

    Timer {
        id: showLongTimeMessage
        interval: 10000
        onTriggered: {
            imgur_top.state = "longtime"
        }
    }

    Connections {
        target: loader
        onImgurPassOn: {
            if(what === "show" || what === "show_anonym") {
                show(what)
            } else if(what === "hide") {
                hide()
            } else if(what === "keyevent") {
                if(param[0] === Qt.Key_Escape)
                    hide()
            }
        }
    }

    Connections {

        target: handlingShareImgur

        onImgurUploadProgress: {

            showLongTimeMessage.restart()

            imgur_top.state = "uploading"

            var p = Math.round(perc*100)
            progresspercentage = p

            if(p == 100)
                state = "busy"

        }

        onImgurImageUrl: {
            console.log("imgur.com image url:", url)
            imgur_top.imageURL = url
        }

        onImgurDeleteHash: {
            console.log("imgur.com delete hash:", url)
            imgur_top.imageDeleteHash = url
        }

        onImgurUploadError: {
            working.showFailure(true)
            showLongTimeMessage.stop()
            errorCode = err
            imgur_top.state = "error"
        }

        onFinished: {
            showLongTimeMessage.stop()
            if(errorCode == -1) {
                working.hide()
                imgur_top.state = "result"
            }
        }


    }

    Timer {
        id: upload_anonym
        interval: 0
        onTriggered: {

            if(!handlingShareImgur.checkIfConnectedToInternet()) {
                working.showFailure(true)
                imgur_top.state = "nointernet"
                return
            }

            working.showBusy()
            handlingShareImgur.anonymousUpload(filefoldermodel.currentFilePath)
        }
    }

    Timer {
        id: upload_account
        interval: 0
        onTriggered: {

            if(!handlingShareImgur.checkIfConnectedToInternet()) {
                working.showFailure(true)
                imgur_top.state = "nointernet"
                return
            }

            working.showBusy()

            handlingShareImgur.authorizeHandlePin("68713a8441")
            var ret = handlingShareImgur.authAccount()
            if(ret !== 0) {
                handlingShareImgur.abort()
                handlingShareImgur.imgurUploadError(-2)
                return
            }
            accountname = handlingShareImgur.getAccountUsername()
            handlingShareImgur.upload(filefoldermodel.currentFilePath)
        }
    }

    function show(what) {

        errorCode = -1
        progresspercentage = 0
        imageURL = ""
        imageDeleteHash = ""

        state = "uploading"

        opacity = 1

        if(what === "show")
            uploadToAccount()
        else
            uploadAnonymously()

    }

    function hide() {

        handlingShareImgur.abort()
        opacity = 0
        variables.visibleItem = ""
    }

    function uploadAnonymously() {
        accountname = ""
        upload_anonym.restart()
    }

    function uploadToAccount() {
        accountname = ""
        upload_account.restart()
    }

}
