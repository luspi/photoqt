/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls

import PQCScriptsShareImgur
import PQCFileFolderModel
import PQCScriptsClipboard
import PQCWindowGeometry

import "../elements"

PQTemplateFullscreen {

    id: imgur_top

    thisis: "imgur"
    popout: PQCSettings.interfacePopoutFilter
    forcePopout: PQCWindowGeometry.imgurForcePopout
    shortcut: "__imgurAnonym"
    title: accountname=="" ?
               qsTranslate("imgur", "Upload to imgur.com") :
               qsTranslate("imgur", "Upload to imgur.com") + ": " + accountname
    showPopinPopout: false

    property string accountname: ""

    button1.text: genericStringCancel

    button2.text: qsTranslate("imgur", "Show past uploads")
    button2.visible: true
    button2.font.weight: PQCLook.fontWeightNormal

    button1.onClicked: {
        hide()
    }

    button2.onClicked: {
        imgurpast.show()
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
                font.weight: PQCLook.fontWeightBold
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
                        text: qsTranslate("imgur", "Click to open in browser")
                        onClicked:
                            Qt.openUrlExternally(parent.text)
                    }
                }

                PQButtonIcon {
                    width: result_access.height
                    height: width
                    source: "image://svg/:/white/copy.svg"
                    onClicked:
                        PQCScriptsClipboard.copyTextToClipboard(imgur_top.imageURL)
                }

            }

            Item {
                width: 1
                height: 10
            }

            PQTextL {
                text: qsTranslate("imgur", "Delete Image")
                font.weight: PQCLook.fontWeightBold
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
                        text: qsTranslate("imgur", "Click to open in browser")
                        onClicked:
                            Qt.openUrlExternally("https://imgur.com/delete/" + imgur_top.imageDeleteHash)
                    }
                }

                PQButtonIcon {
                    width: result_delete.height
                    height: width
                    source: "image://svg/:/white/copy.svg"
                    onClicked:
                        PQCScriptsClipboard.copyTextToClipboard("https://imgur.com/delete/" + imgur_top.imageDeleteHash)
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
            font.weight: PQCLook.fontWeightBold
            text: progresspercentage + "%"
        }

    }

    // Some status message
    PQText {
        id: statusmessage
        x: (parent.width-width)/2
        y: (parent.height-height)/2 + working.circleHeight*0.8
        horizontalAlignment: Text.AlignHCenter
        font.weight: PQCLook.fontWeightBold
    }

    // a fullscreen overlay to show past (cached) uploads
    Rectangle {

        id: imgurpast

        anchors.fill: parent
        color: PQCLook.transColorAccent

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        // no past uploads available
        PQTextL {
            visible: pastview.dat.length==0
            anchors.centerIn: parent
            //: The uploads are uploads to imgur.com
            text: qsTranslate("imgur", "No past uploads found")
            font.weight: PQCLook.fontWeightBold
        }

        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            ListView {

                id: pastview

                property var dat: []
                model: dat.length
                spacing: 10

                clip: true

                width: 600
                height: Math.min(imgurpast.height-200, 500)

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                delegate:
                    Rectangle {

                        id: deleg

                        property var curdata: pastview.dat[index]

                        x: 5
                        width: pastview.width-10
                        height: delegcol.height+10
                        color: PQCLook.baseColor
                        radius: 5

                        // A small button to remove this entry from the cache
                        Image {
                            x: parent.width-width-5
                            y: 5
                            width: 26
                            height: 26
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/white/close.svg"
                            opacity: 0.5
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.opacity = 1
                                onExited: parent.opacity = 0.5
                                onClicked: {
                                    if(PQCScriptsShareImgur.deletePastEntry(curdata[0]))
                                        imgurpast.show()
                                }
                            }
                        }

                        Column {

                            id: delegcol

                            x: 5
                            y: 5

                            // the date of the upload
                            PQTextS {
                                text: curdata[1]
                                font.weight: PQCLook.fontWeightBold
                            }

                            Row {
                                spacing: 10

                                // the cached thumbnail
                                Image {
                                    width: 75
                                    height: 75
                                    fillMode: Image.PreserveAspectFit
                                    source: "image://imgurhistory/" + curdata[0]
                                }

                                Column {

                                    y: (75-height)/2
                                    spacing: 5

                                    // access the image
                                    Row {
                                        PQText {
                                            id: acctxt
                                            //: Used as in: access this image
                                            text: qsTranslate("imgur", "Access:") + " "
                                        }
                                        PQText {
                                            font.weight: PQCLook.fontWeightBold
                                            text: curdata[2]
                                            PQMouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                text: qsTranslate("imgur", "Click to open in browser")
                                                onClicked:
                                                    Qt.openUrlExternally(curdata[2])
                                            }
                                        }
                                        Item {
                                            width: 10
                                            height: 1
                                        }
                                        PQButtonIcon {
                                            width: acctxt.height
                                            height: width
                                            source: "image://svg/:/white/copy.svg"
                                            onClicked:
                                                PQCScriptsClipboard.copyTextToClipboard(curdata[2])
                                        }
                                    }

                                    // delete the image
                                    Row {
                                        PQText {
                                            id: deltxt
                                            //: Used as in: delete this image
                                            text: qsTranslate("imgur", "Delete:") + " "
                                        }
                                        PQText {
                                            font.weight: PQCLook.fontWeightBold
                                            text: "https://imgur.com/delete/" + curdata[3]
                                            PQMouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                text: qsTranslate("imgur", "Click to open in browser")
                                                onClicked:
                                                    Qt.openUrlExternally("https://imgur.com/delete/" + curdata[3])
                                            }
                                        }
                                        Item {
                                            width: 10
                                            height: 1
                                        }
                                        PQButtonIcon {
                                            width: deltxt.height
                                            height: width
                                            source: "image://svg/:/white/copy.svg"
                                            onClicked:
                                                PQCScriptsClipboard.copyTextToClipboard("https://imgur.com/delete/" + curdata[3])
                                        }
                                    }

                                }
                            }
                        }

                    }



            }

            // close and clear buttons
            Row {
                x: (parent.width-width)/2
                PQButton {
                    text: genericStringClose
                    onClicked: {
                        imgurpast.hide()
                    }
                }
                PQButton {
                    //: Written on button, please keep short. Used as in: clear all entries
                    text: qsTranslate("imgur", "Clear all")
                    onClicked: {
                        if(PQCScriptsShareImgur.deletePastEntry("xxx"))
                            imgurpast.show()
                    }
                }
            }

        }

        function show() {
            opacity = 1
            pastview.dat = PQCScriptsShareImgur.getPastUploads()
        }

        function hide() {
            opacity = 0
        }

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

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === "imgur")
                    show()

            } else if(what === "hide") {

                if(param === "imgur")
                    hide()

            } else if(imgur_top.opacity > 0) {

                if(what === "keyEvent") {
                    if(param[0] === Qt.Key_Escape)
                        hide()
                }

            }

        }

    }

    Connections {

        target: PQCScriptsShareImgur
        function onImgurUploadProgress(perc) {

            showLongTimeMessage.restart()

            imgur_top.state = "uploading"

            var p = Math.round(perc*100)
            progresspercentage = p

            if(p == 100)
                state = "busy"

        }

        function onImgurImageUrl(url) {
            console.log("imgur.com image url:", url)
            imgur_top.imageURL = url
        }

        function onImgurDeleteHash(url) {
            console.log("imgur.com delete hash:", url)
            imgur_top.imageDeleteHash = url
        }

        function onImgurUploadError(err) {
            working.showFailure(true)
            showLongTimeMessage.stop()
            errorCode = err
            imgur_top.state = "error"
        }

        function onFinished() {
            showLongTimeMessage.stop()
            if(errorCode == -1) {
                working.hide()
                imgur_top.state = "result"
                PQCScriptsShareImgur.storeNewUpload(PQCFileFolderModel.currentFile, imgur_top.imageURL, imgur_top.imageDeleteHash)
            }
        }


    }

    Timer {
        id: upload_anonym
        interval: 0
        onTriggered: {

            if(!PQCScriptsShareImgur.checkIfConnectedToInternet()) {
                working.showFailure(true)
                imgur_top.state = "nointernet"
                return
            }

            working.showBusy()
            PQCScriptsShareImgur.anonymousUpload(PQCFileFolderModel.currentFile)
        }
    }

    Timer {
        id: upload_account
        interval: 0
        onTriggered: {

            if(!PQCScriptsShareImgur.checkIfConnectedToInternet()) {
                working.showFailure(true)
                imgur_top.state = "nointernet"
                return
            }

            working.showBusy()

            PQCScriptsShareImgur.authorizeHandlePin("68713a8441")
            var ret = PQCScriptsShareImgur.authAccount()
            if(ret !== 0) {
                PQCScriptsShareImgur.abort()
                PQCScriptsShareImgur.imgurUploadError(-2)
                return
            }
            accountname = PQCScriptsShareImgur.getAccountUsername()
            PQCScriptsShareImgur.upload(PQCFileFolderModel.currentFile)
        }
    }

    function show() {

        imgurpast.opacity = 0
        errorCode = -1
        progresspercentage = 0
        imageURL = ""
        imageDeleteHash = ""

        state = "uploading"

        opacity = 1


    }

    function hide() {

        if(imgurpast.visible) {
            imgurpast.hide()
            return
        }

        PQCScriptsShareImgur.abort()
        opacity = 0
        loader.elementClosed("imgur")
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
