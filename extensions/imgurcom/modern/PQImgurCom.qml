/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import PQCScriptsShareImgur
import PQCFileFolderModel

import org.photoqt.qml

PQTemplateFullscreen {

    id: imgur_top

    thisis: "imgurcom"
    popout: PQCSettingsExtensions.ImgurComPopout // qmllint disable unqualified
    forcePopout: PQCWindowGeometry.imgurForcePopout // qmllint disable unqualified
    shortcut: "__imgurAnonym"
    title: (accountname=="" ?
               qsTranslate("imgur", "Upload to imgur.com") :
               qsTranslate("imgur", "Upload to imgur.com") + ": " + accountname)
    showPopinPopout: false

    property string accountname: ""

    button1.text: genericStringCancel

    button2.text: qsTranslate("imgur", "Show past uploads")
    button2.visible: true
    button2.font.weight: PQCLook.fontWeightNormal // qmllint disable unqualified

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

    property bool copy3MenuOpen: false
    property bool copy4MenuOpen: false
    signal closeMenus()

    states: [
        State {
            name: "uploading"
            PropertyChanges {
                statusmessage.opacity: 0
                statusmessage.text: imgur_top.progresspercentage+"%"
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringCancel
            }
        },
        State {
            name: "busy"
            PropertyChanges {
                statusmessage.opacity: 0
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringCancel
            }
        },
        State {
            name: "longtime"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgur", "This seems to take a long time...") + "<br>" +
                                    qsTranslate("imgur", "There might be a problem with your internet connection or the imgur.com servers.")
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringCancel
            }
        },
        State {
            name: "error"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgur", "An Error occurred while uploading image!") + "<br>" +
                                    qsTranslate("imgur", "Error code:") + " " + imgur_top.errorCode
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                working.animationRunning: false
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringClose
            }
        },
        State {
            name: "nointernet"
            PropertyChanges {
                statusmessage.opacity: 1
                statusmessage.text: qsTranslate("imgur", "You do not seem to be connected to the internet...") + "<br>" +
                                    qsTranslate("imgur", "Unable to upload!")
            }
            PropertyChanges {
                progressbar.text: "..."
            }
            PropertyChanges {
                working.animationRunning: false
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringClose
            }
        },
        State {
            name: "result"
            PropertyChanges {
                statusmessage.opacity: 0
            }
            PropertyChanges {
                working.opacity: 0
            }
            PropertyChanges {
                resultscol.opacity: 1
            }
            PropertyChanges {
                imgur_top.button1.text: imgur_top.genericStringClose
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
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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
                            Qt.openUrlExternally(imgur_top.imageURL)
                    }
                }

                PQButtonIcon {
                    id: copy1
                    width: result_access.height
                    height: width
                    source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
                    onClicked:
                        PQCScriptsClipboard.copyTextToClipboard(imgur_top.imageURL) // qmllint disable unqualified
                }

            }

            Item {
                width: 1
                height: 10
            }

            PQTextL {
                text: qsTranslate("imgur", "Delete Image")
                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
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
                    id: copy2
                    width: result_delete.height
                    height: width
                    source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
                    onClicked:
                        PQCScriptsClipboard.copyTextToClipboard("https://imgur.com/delete/" + imgur_top.imageDeleteHash) // qmllint disable unqualified
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
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
            text: imgur_top.progresspercentage + "%"
        }

    }

    // Some status message
    PQText {
        id: statusmessage
        x: (parent.width-width)/2
        y: (parent.height-height)/2 + working.circleHeight*0.8
        horizontalAlignment: Text.AlignHCenter
        font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
    }

    // a fullscreen overlay to show past (cached) uploads
    Rectangle {

        id: imgurpast

        anchors.fill: parent
        color: PQCLook.baseColorAccent // qmllint disable unqualified

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity>0

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        // no past uploads available
        PQTextL {
            visible: pastview.dat.length==0
            anchors.centerIn: parent
            //: The uploads are uploads to imgur.com
            text: qsTranslate("imgur", "No past uploads found")
            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
        }

        Column {

            x: (parent.width-width)/2
            y: (parent.height-height)/2

            ListView {

                id: pastview

                property list<var> dat: []
                model: dat.length
                spacing: 10

                clip: true

                width: 600
                height: Math.min(imgurpast.height-200, 500)

                ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

                delegate:
                    Rectangle {

                        id: deleg

                        required property int modelData

                        property list<var> curdata: pastview.dat[modelData]

                        x: 5
                        width: pastview.width-10
                        height: delegcol.height+10
                        color: PQCLook.baseColor // qmllint disable unqualified
                        radius: 5

                        // A small button to remove this entry from the cache
                        Image {
                            x: parent.width-width-5
                            y: 5
                            width: 26
                            height: 26
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                            opacity: 0.5
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: parent.opacity = 1
                                onExited: parent.opacity = 0.5
                                onClicked: {
                                    if(PQCScriptsShareImgur.deletePastEntry(deleg.curdata[0])) // qmllint disable unqualified
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
                                text: deleg.curdata[1]
                                font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                            }

                            Row {
                                spacing: 10

                                // the cached thumbnail
                                Image {
                                    width: 75
                                    height: 75
                                    fillMode: Image.PreserveAspectFit
                                    source: "image://imgurhistory/" + deleg.curdata[0]
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
                                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                            text: deleg.curdata[2]
                                            PQMouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                text: qsTranslate("imgur", "Click to open in browser")
                                                onClicked:
                                                    Qt.openUrlExternally(deleg.curdata[2])
                                            }
                                        }
                                        Item {
                                            width: 10
                                            height: 1
                                        }
                                        PQButtonIcon {
                                            id: copy3
                                            width: acctxt.height
                                            height: width
                                            contextmenu.onAboutToShow:
                                                imgur_top.copy3MenuOpen = true
                                            contextmenu.onAboutToHide:
                                                imgur_top.copy3MenuOpen = true
                                            Connections {
                                                target: imgur_top
                                                function onCloseMenus() {
                                                    copy3.contextmenu.close()
                                                }
                                            }
                                            source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
                                            onClicked:
                                                PQCScriptsClipboard.copyTextToClipboard(deleg.curdata[2]) // qmllint disable unqualified
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
                                            font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                                            text: "https://imgur.com/delete/" + deleg.curdata[3]
                                            PQMouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                text: qsTranslate("imgur", "Click to open in browser")
                                                onClicked:
                                                    Qt.openUrlExternally("https://imgur.com/delete/" + deleg.curdata[3])
                                            }
                                        }
                                        Item {
                                            width: 10
                                            height: 1
                                        }
                                        PQButtonIcon {
                                            id: copy4
                                            width: deltxt.height
                                            height: width
                                            contextmenu.onAboutToShow:
                                                imgur_top.copy4MenuOpen = true
                                            contextmenu.onAboutToHide:
                                                imgur_top.copy4MenuOpen = true
                                            Connections {
                                                target: imgur_top
                                                function onCloseMenus() {
                                                    copy4.contextmenu.close()
                                                }
                                            }
                                            source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
                                            onClicked:
                                                PQCScriptsClipboard.copyTextToClipboard("https://imgur.com/delete/" + deleg.curdata[3]) // qmllint disable unqualified
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
                    id: closebutton
                    text: genericStringClose
                    onClicked: {
                        imgurpast.hide()
                    }
                }
                PQButton {
                    id: clearbutton
                    //: Written on button, please keep short. Used as in: clear all entries
                    text: qsTranslate("imgur", "Clear all")
                    onClicked: {
                        if(PQCScriptsShareImgur.deletePastEntry("xxx")) // qmllint disable unqualified
                            imgurpast.show()
                    }
                }
            }

        }

        function show() {
            opacity = 1
            pastview.dat = PQCScriptsShareImgur.getPastUploads() // qmllint disable unqualified
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

        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, param : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show" && param[0] === "imgurcom") {

                imgur_top.show()

            } else if(what === "hide" && param[0] === "imgurcom") {

                imgur_top.hide()

            } else if(imgur_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(imgur_top.closeAnyMenu())
                        return

                    if(param[0] === Qt.Key_Escape)
                        imgur_top.hide()
                }

            }

        }

    }

    Connections {

        target: PQCScriptsShareImgur // qmllint disable unqualified

        function onImgurUploadProgress(perc : real) {

            showLongTimeMessage.restart()

            imgur_top.state = "uploading"

            var p = Math.round(perc*100)
            imgur_top.progresspercentage = p

            if(p == 100)
                imgur_top.state = "busy"

        }

        function onImgurImageUrl(theurl : string) {
            console.log("imgur.com image url:", theurl)
            imgur_top.imageURL = theurl // qmllint disable unqualified
        }

        function onImgurDeleteHash(theurl : string) {
            console.log("imgur.com delete hash:", theurl)
            imgur_top.imageDeleteHash = theurl
        }

        function onImgurUploadError(err : string) {
            working.showFailure(true)
            showLongTimeMessage.stop()
            imgur_top.errorCode = err
            imgur_top.state = "error"
        }

        function onFinished() {
            showLongTimeMessage.stop()
            if(imgur_top.errorCode == -1) {
                working.hide()
                imgur_top.state = "result"
                PQCScriptsShareImgur.storeNewUpload(PQCFileFolderModel.currentFile, imgur_top.imageURL, imgur_top.imageDeleteHash) // qmllint disable unqualified
            }
        }


    }

    Timer {
        id: upload_anonym
        interval: 0
        onTriggered: {

            if(!PQCScriptsShareImgur.checkIfConnectedToInternet()) { // qmllint disable unqualified
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

            if(!PQCScriptsShareImgur.checkIfConnectedToInternet()) { // qmllint disable unqualified
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
            imgur_top.accountname = PQCScriptsShareImgur.getAccountUsername()
            PQCScriptsShareImgur.upload(PQCFileFolderModel.currentFile)
        }
    }

    function closeAnyMenu() {
        if(copy1.contextmenu.visible) {
            copy1.contextmenu.close()
            return true
        } else if(copy2.contextmenu.visible) {
            copy2.contextmenu.close()
            return true
        } else if(imgur_top.copy3MenuOpen || imgur_top.copy4MenuOpen) {
            imgur_top.closeMenus()
            return true
        } else if(closebutton.contextmenu.visible) {
            closebutton.contextmenu.close()
            return true
        } else if(clearbutton.contextmenu.visible) {
            clearbutton.contextmenu.close()
            return true
        } else if(imgur_top.contextMenuOpen) {
            imgur_top.closeContextMenus()
            return true
        }
        return false
    }

    function show() {

        imgurpast.opacity = 0
        errorCode = -1
        progresspercentage = 0
        imageURL = ""
        imageDeleteHash = ""

        state = "uploading"

        opacity = 1
        if(popoutWindowUsed)
            imgur_popout.visible = true // qmllint disable unqualified

        if(PQCConstants.lastExecutedShortcutCommand === "__imgurAnonym")
            uploadAnonymously()
        else if(PQCConstants.lastExecutedShortcutCommand === "__imgur")
            uploadToAccount()
        else
            hide()

    }

    function hide() {

        closeAnyMenu()

        if(imgurpast.visible) {
            imgurpast.hide()
            return
        }

        PQCScriptsShareImgur.abort() // qmllint disable unqualified
        opacity = 0
        if(popoutWindowUsed && imgur_popout.visible)
            imgur_popout.visible = false
        else
            PQCNotify.loaderRegisterClose("imgurcom")
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
